from urllib.parse import quote
import requests
from config import DOCKING_FILES_DIR

def get_pubchem_compound(query: str) -> dict | None:
    query = query.strip()
    identifier = f"cid/{query}" if query.isdigit() else f"name/{quote(query, safe='')}"
    url = (
        "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/"
        f"{identifier}/property/MolecularFormula,MolecularWeight,ConnectivitySMILES,XLogP,TPSA,HBondDonorCount,HBondAcceptorCount,RotatableBondCount/JSON"
    )
    response = requests.get(url, timeout=20)
    if response.status_code == 404:
        return None
    response.raise_for_status()
    properties = response.json().get("PropertyTable", {}).get("Properties", [])
    return properties[0] if properties else None


def lipinski_rule_screen(compound: dict) -> dict:
    required = {
        "MolecularWeight": "molecular weight <= 500 Da",
        "XLogP": "XLogP <= 5",
        "HBondDonorCount": "hydrogen-bond donors <= 5",
        "HBondAcceptorCount": "hydrogen-bond acceptors <= 10",
    }
    if any(compound.get(key) is None for key in required):
        return {"available": False, "status": "Required PubChem descriptors are unavailable.", "violations": []}

    values = {
        "MolecularWeight": float(compound["MolecularWeight"]),
        "XLogP": float(compound["XLogP"]),
        "HBondDonorCount": int(compound["HBondDonorCount"]),
        "HBondAcceptorCount": int(compound["HBondAcceptorCount"]),
    }
    limits = {
        "MolecularWeight": 500,
        "XLogP": 5,
        "HBondDonorCount": 5,
        "HBondAcceptorCount": 10,
    }
    violations = [
        {"descriptor": required[key], "observed": value}
        for key, value in values.items()
        if value > limits[key]
    ]
    count = len(violations)
    status = "No Lipinski Rule-of-Five violations" if count == 0 else f"{count} Lipinski Rule-of-Five violation{'s' if count != 1 else ''}"
    return {"available": True, "status": status, "violation_count": count, "violations": violations}


def download_ligand_sdf(cid: str) -> str | None:
    sdf_path = DOCKING_FILES_DIR / "ligands" / f"{cid}.sdf"
    if sdf_path.exists() and sdf_path.stat().st_size > 0:
        return str(sdf_path)

    # Try 3D conformer SDF first
    url_3d = f"https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{cid}/SDF?record_type=3d"
    try:
        response = requests.get(url_3d, timeout=30)
        if response.status_code == 200 and len(response.content) > 0:
            with open(sdf_path, "wb") as f:
                f.write(response.content)
            return str(sdf_path)
    except Exception:
        pass

    # Fallback to standard 2D SDF if 3D conformer is not pre-computed in PubChem
    url_2d = f"https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{cid}/SDF"
    try:
        response = requests.get(url_2d, timeout=30)
        if response.status_code == 200 and len(response.content) > 0:
            with open(sdf_path, "wb") as f:
                f.write(response.content)
            return str(sdf_path)
    except Exception:
        pass

    return None
