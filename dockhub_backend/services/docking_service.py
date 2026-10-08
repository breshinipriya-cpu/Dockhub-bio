import os
import re
import subprocess
from config import DOCKING_FILES_DIR, VINA_EXE, MGLTOOLS_PYTHON, PREPARE_RECEPTOR, OPENBABEL_EXE

def calculate_receptor_center(protein_pdb_path: str) -> tuple[float, float, float]:
    x_coords = []
    y_coords = []
    z_coords = []

    with open(protein_pdb_path, "r") as f:
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

    if os.path.exists(output_path):
        os.remove(output_path)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    command = [
        MGLTOOLS_PYTHON,
        PREPARE_RECEPTOR,
        "-r", protein_pdb_path,
        "-o", output_path,
        "-A", "hydrogens"
    ]

    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode != 0 or not os.path.exists(output_path):
        return None

    return output_path


def convert_ligand_to_pdbqt(ligand_sdf_path: str) -> str | None:
    ligand_name = os.path.splitext(os.path.basename(ligand_sdf_path))[0]
    output_path = str(DOCKING_FILES_DIR / "pdbqt" / f"{ligand_name}_ligand.pdbqt")

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    command = [
        OPENBABEL_EXE,
        ligand_sdf_path,
        "-O",
        output_path,
    ]

    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode != 0:
        return None

    return output_path if os.path.exists(output_path) else None
