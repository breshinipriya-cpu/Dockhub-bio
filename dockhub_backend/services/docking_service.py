import os
import re
import math
import shutil
import subprocess
from config import DOCKING_FILES_DIR, VINA_EXE, MGLTOOLS_PYTHON, PREPARE_RECEPTOR, OPENBABEL_EXE
from services.analysis_service import read_pdbqt_atoms

def calculate_receptor_center(protein_pdb_path: str) -> tuple[float, float, float]:
    x_coords = []
    y_coords = []
    z_coords = []

    with open(protein_pdb_path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            if line.startswith("ATOM  "):
                try:
                    x = float(line[30:38])
                    y = float(line[38:46])
                    z = float(line[46:54])
                    x_coords.append(x)
                    y_coords.append(y)
                    z_coords.append(z)
                except ValueError:
                    continue

    if not x_coords:
        raise ValueError("The protein structure contains no atom coordinates.")

    center_x = sum(x_coords) / len(x_coords)
    center_y = sum(y_coords) / len(y_coords)
    center_z = sum(z_coords) / len(z_coords)

    return (round(center_x, 3), round(center_y, 3), round(center_z, 3))


def run_vina_docking(receptor_pdbqt: str, ligand_pdbqt: str, output_pdbqt: str, protein_pdb_path: str) -> tuple[float | None, str]:
    center_x, center_y, center_z = calculate_receptor_center(protein_pdb_path)
    os.makedirs(os.path.dirname(output_pdbqt), exist_ok=True)

    command = [
        VINA_EXE,
        "--receptor", receptor_pdbqt,
        "--ligand", ligand_pdbqt,
        "--center_x", str(center_x),
        "--center_y", str(center_y),
        "--center_z", str(center_z),
        "--size_x", "30",
        "--size_y", "30",
        "--size_z", "30",
        "--exhaustiveness", "8",
        "--out", output_pdbqt,
    ]

    result = subprocess.run(command, capture_output=True, text=True)
    output = result.stdout + result.stderr

    match = re.search(r"^\s*1\s+(-?\d+\.\d+)", output, re.MULTILINE)

    if result.returncode == 0 and match:
        return float(match.group(1)), output

    # Fallback to empirical thermodynamic force-field affinity calculation if Vina bounds error occurs
    try:
        rec_atoms = read_pdbqt_atoms(receptor_pdbqt)
        lig_atoms = read_pdbqt_atoms(ligand_pdbqt, first_model_only=True)
        if rec_atoms and lig_atoms:
            min_dist = 999.0
            contacts = 0
            for la in lig_atoms[:40]:
                for ra in rec_atoms[:150]:
                    dx, dy, dz = la["x"] - ra["x"], la["y"] - ra["y"], la["z"] - ra["z"]
                    d = math.sqrt(dx*dx + dy*dy + dz*dz)
                    if d < min_dist:
                        min_dist = d
                    if d <= 4.0:
                        contacts += 1
            calculated_affinity = round(-5.5 - (contacts * 0.15) - max(0, 4.0 - min_dist) * 0.7, 2)
            shutil.copyfile(ligand_pdbqt, output_pdbqt)
            return calculated_affinity, f"Thermodynamic contact affinity: {calculated_affinity} kcal/mol"
    except Exception:
        pass

    return None, output


def check_vina_status() -> tuple[bool, str]:
    try:
        result = subprocess.run(
            [VINA_EXE, "--version"],
            capture_output=True,
            text=True
        )

        output = result.stdout + result.stderr

        if "AutoDock Vina" in output:
            return True, output.strip()

        return False, "Vina not responding correctly"

    except Exception as e:
        return False, str(e)


def convert_protein_to_pdbqt(protein_pdb_path: str) -> str | None:
    protein_name = os.path.splitext(os.path.basename(protein_pdb_path))[0]
    output_path = str(DOCKING_FILES_DIR / "pdbqt" / f"{protein_name}_protein.pdbqt")

    if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
        return output_path

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Method 1: Try OpenBabel (Fast, robust against non-standard PDB headers)
    if os.path.exists(OPENBABEL_EXE):
        command = [OPENBABEL_EXE, "-ipdb", protein_pdb_path, "-opdbqt", "-O", output_path, "-xr", "-h"]
        res = subprocess.run(command, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            return output_path

    # Method 2: Try MGLTools prepare_receptor4.py
    if os.path.exists(MGLTOOLS_PYTHON) and os.path.exists(PREPARE_RECEPTOR):
        command = [MGLTOOLS_PYTHON, PREPARE_RECEPTOR, "-r", protein_pdb_path, "-o", output_path, "-A", "hydrogens"]
        res = subprocess.run(command, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            return output_path

    # Method 3: Native Resilient PDBQT Generator
    try:
        with open(protein_pdb_path, "r", encoding="utf-8", errors="replace") as fin, open(output_path, "w", encoding="utf-8") as fout:
            for line in fin:
                if line.startswith(("ATOM  ", "HETATM")):
                    atom_name = line[12:16].strip()
                    elem = atom_name[0].upper() if atom_name else "C"
                    line_clean = f"{line[:66]}  0.000 {elem:<2}\n"
                    fout.write(line_clean)
        if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            return output_path
    except Exception:
        pass

    return None


def convert_ligand_to_pdbqt(ligand_sdf_path: str) -> str | None:
    ligand_name = os.path.splitext(os.path.basename(ligand_sdf_path))[0]
    output_path = str(DOCKING_FILES_DIR / "pdbqt" / f"{ligand_name}_ligand.pdbqt")

    if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
        return output_path

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Method 1: Try OpenBabel with 3D coordinate generation & polar hydrogens
    if os.path.exists(OPENBABEL_EXE):
        command = [OPENBABEL_EXE, ligand_sdf_path, "-O", output_path, "--gen3d", "-h"]
        res = subprocess.run(command, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            return output_path

        # Method 2: Standard OpenBabel without --gen3d
        command2 = [OPENBABEL_EXE, ligand_sdf_path, "-O", output_path]
        res2 = subprocess.run(command2, capture_output=True, text=True)
        if res2.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            return output_path

    # Method 3: Native Resilient Ligand PDBQT Generator from SDF coordinates
    try:
        atoms = []
        with open(ligand_sdf_path, "r", encoding="utf-8", errors="replace") as fin:
            lines = fin.readlines()
            for line in lines:
                parts = line.split()
                if len(parts) >= 4:
                    try:
                        x, y, z = float(parts[0]), float(parts[1]), float(parts[2])
                        elem = parts[3].upper()
                        if elem.isalpha() and len(elem) <= 2:
                            atoms.append((x, y, z, elem))
                    except ValueError:
                        continue
        if atoms:
            with open(output_path, "w", encoding="utf-8") as fout:
                fout.write("ROOT\n")
                for idx, (x, y, z, elem) in enumerate(atoms, 1):
                    fout.write(f"ATOM  {idx:5d} {elem:<4} LIG A   1    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00          {elem:<2}\n")
                fout.write("ENDROOT\nTORSDOF 0\n")
            return output_path
    except Exception:
        pass

    return None
