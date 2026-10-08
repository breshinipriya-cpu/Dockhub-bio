import math
from Bio.PDB import PDBParser
from Bio.PDB.vectors import calc_dihedral

def read_pdbqt_atoms(path: str, first_model_only: bool = False) -> list[dict]:
    atoms = []
    model_seen = False
    with open(path, "r", encoding="utf-8", errors="replace") as structure_file:
        for line in structure_file:
            if line.startswith("MODEL"):
                if model_seen and first_model_only:
                    break
                model_seen = True
                continue
            if line.startswith("ENDMDL") and first_model_only:
                break
            if not line.startswith(("ATOM  ", "HETATM")):
                continue
            try:
                atom_type = line.split()[-1].upper()
                atoms.append({
                    "name": line[12:16].strip(),
                    "type": atom_type,
                    "x": float(line[30:38]),
                    "y": float(line[38:46]),
                    "z": float(line[46:54]),
                    "residue": f"{line[21:22].strip()}:{line[17:20].strip()}{line[22:27].strip()}",
                })
            except (IndexError, ValueError):
                continue
    return atoms


def analyze_pose_contacts(receptor_path: str, pose_path: str) -> dict:
    receptor_atoms = read_pdbqt_atoms(receptor_path)
    ligand_atoms = read_pdbqt_atoms(pose_path, first_model_only=True)
    if not receptor_atoms or not ligand_atoms:
        raise ValueError("Receptor or docked pose has no readable PDBQT atoms.")

    residue_contacts = {}
    hydrophobic_residues = set()
    hydrogen_bond_candidates = []
    heavy_atom_contact_count = 0
    acceptor_types = {"NA", "OA"}
    donor_hydrogen_types = {"HD"}

    for ligand_atom in ligand_atoms:
        for receptor_atom in receptor_atoms:
            dx = ligand_atom["x"] - receptor_atom["x"]
            dy = ligand_atom["y"] - receptor_atom["y"]
            dz = ligand_atom["z"] - receptor_atom["z"]
            distance = math.sqrt(dx * dx + dy * dy + dz * dz)

            if distance <= 4.0 and ligand_atom["type"] not in {"H", "HD", "HS"} and receptor_atom["type"] not in {"H", "HD", "HS"}:
                heavy_atom_contact_count += 1
                residue = receptor_atom["residue"]
                current = residue_contacts.setdefault(residue, {"residue": residue, "atom_contacts": 0, "minimum_distance_angstrom": distance})
                current["atom_contacts"] += 1
                current["minimum_distance_angstrom"] = min(current["minimum_distance_angstrom"], distance)
                if ligand_atom["type"] in {"C", "A"} and receptor_atom["type"] in {"C", "A"}:
                    hydrophobic_residues.add(residue)

            ligand_is_donor_hydrogen = ligand_atom["type"] in donor_hydrogen_types
            receptor_is_donor_hydrogen = receptor_atom["type"] in donor_hydrogen_types
            ligand_is_acceptor = ligand_atom["type"] in acceptor_types
            receptor_is_acceptor = receptor_atom["type"] in acceptor_types
            if distance <= 3.5 and (
                (ligand_is_donor_hydrogen and receptor_is_acceptor)
                or (receptor_is_donor_hydrogen and ligand_is_acceptor)
            ):
                hydrogen_bond_candidates.append({
                    "ligand_atom": ligand_atom["name"],
                    "protein_atom": receptor_atom["name"],
                    "residue": receptor_atom["residue"],
                    "distance_angstrom": round(distance, 2),
                })

    contacts = sorted(residue_contacts.values(), key=lambda item: item["minimum_distance_angstrom"])
    for contact in contacts:
        contact["minimum_distance_angstrom"] = round(contact["minimum_distance_angstrom"], 2)
    return {
        "heavy_atom_contact_count": heavy_atom_contact_count,
        "residue_contact_count": len(contacts),
        "hydrophobic_residue_contact_count": len(hydrophobic_residues),
        "hydrogen_bond_candidate_count": len(hydrogen_bond_candidates),
        "hydrogen_bond_candidates": hydrogen_bond_candidates,
        "residue_contacts": contacts,
        "method": "PDBQT atom-distance screen: heavy-atom contacts <=4.0 A; donor-H/acceptor candidates <=3.5 A.",
    }


def calculate_ramachandran_points(protein_pdb_path: str) -> list[dict]:
    structure = PDBParser(QUIET=True).get_structure("protein", protein_pdb_path)
    points = []
    for chain in structure[0]:
        residues = [residue for residue in chain if residue.id[0] == " " and all(residue.has_id(atom) for atom in ("N", "CA", "C"))]
        for index, residue in enumerate(residues):
            if index == 0 or index + 1 >= len(residues):
                continue
            previous = residues[index - 1]
            following = residues[index + 1]
            if previous["C"] - residue["N"] > 2.0 or residue["C"] - following["N"] > 2.0:
                continue
            phi = math.degrees(calc_dihedral(
                previous["C"].get_vector(), residue["N"].get_vector(),
                residue["CA"].get_vector(), residue["C"].get_vector(),
            ))
            psi = math.degrees(calc_dihedral(
                residue["N"].get_vector(), residue["CA"].get_vector(),
                residue["C"].get_vector(), following["N"].get_vector(),
            ))
            points.append({
                "chain": chain.id,
                "residue_number": residue.id[1],
                "residue_name": residue.resname,
                "phi": round(phi, 2),
                "psi": round(psi, 2),
            })
    return points
