import re
import requests
from config import DOCKING_FILES_DIR

def search_pdb_ids(query: str, limit: int = 5) -> list[str]:
    query = query.strip()
    if re.fullmatch(r"[A-Za-z0-9]{4}", query):
        return [query.upper()]

    payload = {
        "query": {
            "type": "terminal",
            "service": "text",
            "parameters": {
                "attribute": "struct.title",
                "operator": "contains_phrase",
                "value": query,
            },
        },
        "return_type": "entry",
        "request_options": {"paginate": {"start": 0, "rows": limit}},
    }
    response = requests.post(
        "https://search.rcsb.org/rcsbsearch/v2/query",
        json=payload,
        timeout=20,
    )
    if response.status_code == 204:
        return []
    response.raise_for_status()
    return [entry["identifier"].upper() for entry in response.json().get("result_set", [])]


def get_protein_metadata(protein_id: str) -> dict | None:
    response = requests.get(
        f"https://data.rcsb.org/rest/v1/core/entry/{protein_id}",
        timeout=20,
    )
    if response.status_code == 404:
        return None
    response.raise_for_status()
    entry = response.json()

    organism = None
    entity_ids = entry.get("rcsb_entry_container_identifiers", {}).get("polymer_entity_ids", [])
    for entity_id in entity_ids:
        entity_response = requests.get(
            f"https://data.rcsb.org/rest/v1/core/polymer_entity/{protein_id}/{entity_id}",
            timeout=20,
        )
        if entity_response.status_code != 200:
            continue
        entity = entity_response.json()
        for source_key in ("entity_src_gen", "entity_src_nat", "pdbx_entity_src_syn"):
            sources = entity.get(source_key) or []
            if sources:
                organism = (
                    sources[0].get("pdbx_gene_src_scientific_name")
                    or sources[0].get("pdbx_organism_scientific")
                    or sources[0].get("organism_scientific")
                )
                if organism:
                    break
        if organism:
            break

    methods = [item.get("method") for item in entry.get("exptl", []) if item.get("method")]
    method_str = ", ".join(methods) if methods else None

    resolutions = entry.get("rcsb_entry_info", {}).get("resolution_combined") or []
    if not resolutions:
        diffrn_high = entry.get("rcsb_entry_info", {}).get("diffrn_resolution_high")
        if diffrn_high:
            resolutions = [diffrn_high]

    if resolutions and resolutions[0] is not None:
        val = str(resolutions[0]).strip()
        resolution_str = f"{val} Å" if not val.endswith("Å") else val
    elif method_str and "NMR" in method_str.upper():
        resolution_str = "N/A (NMR Structure)"
    else:
        resolution_str = "N/A"

    return {
        "pdb_id": protein_id,
        "protein_name": entry.get("struct", {}).get("title", protein_id),
        "organism": organism,
        "experimental_method": method_str or "N/A",
        "resolution": resolution_str,
    }


def download_protein_pdb(protein_id: str) -> str | None:
    pdb_path = DOCKING_FILES_DIR / "proteins" / f"{protein_id}.pdb"
    if pdb_path.exists() and pdb_path.stat().st_size > 0:
        return str(pdb_path)

    url = f"https://files.rcsb.org/download/{protein_id}.pdb"
    response = requests.get(url, timeout=30)
    if response.status_code != 200:
        return None

    with open(pdb_path, "wb") as f:
        f.write(response.content)

    return str(pdb_path)
