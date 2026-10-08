from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import requests
import hashlib

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "DockHub Bio Backend is running"}


def stable_number(seed_text, min_value, max_value):
    seed = int(hashlib.sha256(seed_text.encode()).hexdigest(), 16)
    value = min_value + (seed % 10000) / 10000 * (max_value - min_value)
    return round(value, 2)


@app.get("/analyze")
def analyze(protein: str, ligand: str):

    # Fetch protein from RCSB PDB
    pdb_url = (
        "https://search.rcsb.org/rcsbsearch/v2/query?json="
        f"{{\"query\":{{\"type\":\"terminal\",\"service\":\"text\","
        f"\"parameters\":{{\"attribute\":\"struct.title\","
        f"\"operator\":\"contains_phrase\",\"value\":\"{protein}\"}}}},"
        f"\"return_type\":\"entry\","
        f"\"request_options\":{{\"paginate\":{{\"start\":0,\"rows\":1}}}}}}"
    )

    protein_id = "Not Found"

    try:
        pdb_response = requests.get(pdb_url, timeout=15)

        if pdb_response.status_code == 200:
            data = pdb_response.json()

            if "result_set" in data and len(data["result_set"]) > 0:
                protein_id = data["result_set"][0]["identifier"]

    except Exception:
        protein_id = "PDB fetch error"

    # Fetch ligand from PubChem
    ligand_url = (
        "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/"
        f"{ligand}/property/MolecularFormula,MolecularWeight,CanonicalSMILES/JSON"
    )

    formula = "-"
    weight = "-"
    smiles = "-"
    cid = "-"

    try:
        ligand_response = requests.get(ligand_url, timeout=15)

        if ligand_response.status_code == 200:
            ligand_data = ligand_response.json()

            if "PropertyTable" in ligand_data:
                compound = ligand_data["PropertyTable"]["Properties"][0]

                cid = str(compound.get("CID", "-"))
                formula = compound.get("MolecularFormula", "-")
                weight = str(compound.get("MolecularWeight", "-"))
                smiles = compound.get("CanonicalSMILES", "-")

    except Exception:
        formula = "PubChem fetch error"

    # Stable realistic demo values
    seed_text = protein.lower() + "_" + ligand.lower()

    docking_score = stable_number(seed_text, -10.5, -6.0)

    binding_affinity = "High" if docking_score <= -8.0 else "Moderate"
    interaction_status = "Stable" if docking_score <= -7.0 else "Moderately Stable"

    hydrogen_bonds = int(stable_number(seed_text + "_hbond", 2, 7))
    hydrophobic_interactions = int(stable_number(seed_text + "_hydrophobic", 4, 10))

    try:
        weight_value = float(weight)
    except Exception:
        weight_value = 300.0

    absorption = "Good" if weight_value < 500 else "Moderate"
    drug_likeness = "Passed" if weight_value < 500 else "Failed"
    toxicity_risk = "Low" if weight_value < 350 else "Moderate"

    ramachandran_favored = stable_number(seed_text + "_favored", 89.0, 96.0)
    ramachandran_allowed = stable_number(seed_text + "_allowed", 3.0, 9.0)
    ramachandran_outlier = round(100 - ramachandran_favored - ramachandran_allowed, 2)

    if ramachandran_outlier < 0:
        ramachandran_outlier = 0.5

    return {
        "protein_name": protein,
        "protein_id": protein_id,
        "ligand_name": ligand,
        "compound_cid": cid,
        "molecular_formula": formula,
        "molecular_weight": weight,
        "canonical_smiles": smiles,
        "docking_score": docking_score,
        "binding_affinity": binding_affinity,
        "interaction_status": interaction_status,
        "hydrogen_bonds": hydrogen_bonds,
        "hydrophobic_interactions": hydrophobic_interactions,
        "absorption": absorption,
        "drug_likeness": drug_likeness,
        "toxicity_risk": toxicity_risk,
        "ramachandran_favored": ramachandran_favored,
        "ramachandran_allowed": ramachandran_allowed,
        "ramachandran_outlier": ramachandran_outlier,
    }