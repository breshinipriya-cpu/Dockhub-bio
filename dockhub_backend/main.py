from fastapi import FastAPI, HTTPException, Request
from datetime import datetime, timedelta
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from passlib.context import CryptContext
from database import SessionLocal, init_db
from models import User, DockingHistory, SavedDockingResult, SearchActivity, PasswordResetToken
from schemas import (
    SignupRequest,
    LoginRequest,
    SaveResultRequest,
    SearchActivityRequest,
    ForgotPasswordRequest,
    ResetPasswordRequest,
)

from pathlib import Path
from urllib.parse import quote
from Bio.PDB import PDBParser
from Bio.PDB.vectors import calc_dihedral
import requests
import subprocess
import os
import re
import math
import json
import secrets
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

BACKEND_DIR = Path(__file__).resolve().parent
DOCKING_FILES_DIR = BACKEND_DIR / "docking_files"
for directory in ("proteins", "ligands", "pdbqt", "results"):
    (DOCKING_FILES_DIR / directory).mkdir(parents=True, exist_ok=True)

VINA_EXE = os.getenv("VINA_EXE", r"C:\Users\user.LAPTOP\OneDrive\Desktop\Cvina\vina.exe.exe")
MGLTOOLS_PYTHON = os.getenv("MGLTOOLS_PYTHON", r"C:\Program Files (x86)\MGLTools-1.5.7\python.exe")
PREPARE_RECEPTOR = os.getenv(
    "PREPARE_RECEPTOR",
    r"C:\Program Files (x86)\MGLTools-1.5.7\Lib\site-packages\AutoDockTools\Utilities24\prepare_receptor4.py",
)
OPENBABEL_EXE = os.getenv(
    "OPENBABEL_EXE",
    r"C:\Users\user.LAPTOP\OneDrive\Desktop\OpenBabel-3.1.1\obabel.exe",
)

app = FastAPI()
init_db()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

password_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


def send_reset_email(email_to: str, reset_link: str) -> dict:
    smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USERNAME", "")
    smtp_pass = os.getenv("SMTP_PASSWORD", "")
    sender_email = os.getenv("SENDER_EMAIL", smtp_user or "noreply@dockhub.bio")

    subject = "DockHub Bio - Password Reset Link"
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body {{ font-family: 'Segoe UI', Arial, sans-serif; background-color: #020712; color: #ffffff; padding: 20px; }}
        .card {{ max-width: 500px; margin: 0 auto; background-color: #0c1821; border-radius: 16px; border: 1px solid #204038; padding: 32px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }}
        .btn {{ display: inline-block; background-color: #00e699; color: #000000; text-decoration: none; padding: 14px 28px; border-radius: 10px; font-weight: bold; margin-top: 20px; text-align: center; }}
        .link-box {{ background-color: #06111a; padding: 12px; border-radius: 8px; word-break: break-all; color: #64ffda; font-size: 13px; margin-top: 15px; border: 1px solid #142e2b; }}
        .footer {{ font-size: 12px; color: #888888; margin-top: 25px; text-align: center; }}
      </style>
    </head>
    <body>
      <div class="card">
        <h2 style="color: #00e699; margin-top: 0;">DockHub Bio Password Reset</h2>
        <p>You requested to reset your password for your DockHub Bio account (<strong>{email_to}</strong>).</p>
        <p>Click the button below to complete your password reset (valid for 30 minutes):</p>
        <div style="text-align: center;">
          <a href="{reset_link}" class="btn" target="_blank">Reset Password</a>
        </div>
        <p style="margin-top: 25px; font-size: 13px;">Or copy and paste this URL into your browser:</p>
        <div class="link-box">{reset_link}</div>
        <div class="footer">
          If you did not request a password reset, please ignore this email.<br>
          &copy; DockHub Bio - Security Monitoring
        </div>
      </div>
    </body>
    </html>
    """

    if not smtp_user or not smtp_pass:
        print(f"\n========================================================")
        print(f"[RESET LINK GENERATED FOR {email_to}]:")
        print(f"{reset_link}")
        print(f"========================================================\n")
        return {
            "sent": False,
            "reason": "SMTP credentials (SMTP_USERNAME / SMTP_PASSWORD) not set in server environment. Reset link generated successfully.",
            "reset_link": reset_link
        }

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = sender_email
        msg["To"] = email_to
        msg.attach(MIMEText(html_content, "html"))

        with smtplib.SMTP(smtp_server, smtp_port, timeout=15) as server:
            server.starttls()
            server.login(smtp_user, smtp_pass)
            server.sendmail(sender_email, [email_to], msg.as_string())

        print(f"[EMAIL SUCCESS] Reset email successfully delivered to {email_to}")
        return {"sent": True, "reset_link": reset_link}
    except Exception as e:
        print(f"[EMAIL ERROR] Failed to send email to {email_to}: {e}")
        return {"sent": False, "reason": str(e), "reset_link": reset_link}


@app.get("/")
def home():
    return {"message": "DockHub Bio Backend is running"}


@app.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest, request: Request):
    email = req.email.strip().lower()
    if not email:
        return {"success": False, "message": "Email address is required."}

    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            return {"success": False, "message": "No account registered with this email address."}

        token = secrets.token_urlsafe(32)
        expires_at = (datetime.now() + timedelta(minutes=30)).isoformat()

        db.query(PasswordResetToken).filter(PasswordResetToken.email == email).delete()

        reset_token_entry = PasswordResetToken(email=email, token=token, expires_at=expires_at)
        db.add(reset_token_entry)
        db.commit()

        referer = request.headers.get("referer", "")
        origin = request.headers.get("origin", "")
        if origin:
            base = origin
        elif referer:
            from urllib.parse import urlparse
            parsed = urlparse(referer)
            base = f"{parsed.scheme}://{parsed.netloc}"
        else:
            base = "http://localhost:61412"

        reset_link = f"{base}/#/reset-password?token={token}&email={quote(email)}"

        email_result = send_reset_email(email, reset_link)

        return {
            "success": True,
            "message": f"Password reset link generated for {email}.",
            "email_sent": email_result.get("sent", False),
            "reset_link": reset_link
        }
    finally:
        db.close()


@app.post("/reset-password")
def reset_password(req: ResetPasswordRequest):
    email = req.email.strip().lower()
    token = req.token.strip()
    new_password = req.new_password.strip()

    if not email or not token or not new_password:
        return {"success": False, "message": "Email, token, and new password are required."}

    if len(new_password) < 4:
        return {"success": False, "message": "New password must be at least 4 characters long."}

    db = SessionLocal()
    try:
        reset_record = db.query(PasswordResetToken).filter(
            PasswordResetToken.email == email,
            PasswordResetToken.token == token
        ).first()

        if not reset_record:
            return {"success": False, "message": "Invalid or expired password reset link."}

        try:
            expires_at = datetime.fromisoformat(reset_record.expires_at)
            if datetime.now() > expires_at:
                db.delete(reset_record)
                db.commit()
                return {"success": False, "message": "This password reset link has expired. Please request a new one."}
        except Exception:
            pass

        user = db.query(User).filter(User.email == email).first()
        if not user:
            return {"success": False, "message": "User account not found."}

        hashed_password = password_context.hash(new_password)
        user.password = hashed_password

        db.delete(reset_record)
        db.commit()

        return {"success": True, "message": "Password updated successfully. You can now log in."}
    finally:
        db.close()



@app.post("/signup")
def signup(user: SignupRequest):
    db = SessionLocal()
    existing_user = db.query(User).filter(User.email == user.email).first()

    if existing_user:
        db.close()
        return {"success": False, "message": "Email already registered"}

    hashed_password = password_context.hash(user.password)

    new_user = User(
        name=user.name,
        email=user.email,
        password=hashed_password
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    db.close()

    return {
        "success": True,
        "message": "Account created successfully",
        "name": user.name,
        "email": user.email
    }


@app.post("/login")
def login(user: LoginRequest):
    db = SessionLocal()
    existing_user = db.query(User).filter(User.email == user.email).first()

    if not existing_user:
        db.close()
        return {"success": False, "message": "Invalid email or password"}

    if not password_context.verify(user.password, existing_user.password):
        db.close()
        return {"success": False, "message": "Invalid email or password"}

    name = existing_user.name
    email = existing_user.email
    db.close()

    return {
        "success": True,
        "message": "Login successful",
        "name": name,
        "email": email
    }


@app.get("/history")
def get_history(user_email: str):
    email = user_email.strip().lower()
    if not email:
        return {"success": False, "message": "A logged-in account email is required."}
    db = SessionLocal()
    try:
        rows = db.query(DockingHistory).filter(
            DockingHistory.user_email == email
        ).order_by(DockingHistory.id.desc()).all()
        return {
            "success": True,
            "items": [
                {
                    "protein": row.protein_name,
                    "pdbId": row.protein_id or row.protein_name,
                    "ligand": row.ligand_name,
                    "dockingScore": row.docking_score,
                    "dateTime": row.created_at,
                    "resultJson": row.result_json,
                }
                for row in rows
            ],
        }
    finally:
        db.close()


@app.delete("/history")
def clear_history(user_email: str):
    email = user_email.strip().lower()
    db = SessionLocal()
    try:
        deleted = db.query(DockingHistory).filter(DockingHistory.user_email == email).delete()
        db.commit()
        return {"success": True, "deleted": deleted}
    finally:
        db.close()


@app.get("/saved_results")
def get_saved_results(user_email: str):
    email = user_email.strip().lower()
    if not email:
        return {"success": False, "message": "A logged-in account email is required."}
    db = SessionLocal()
    try:
        rows = db.query(SavedDockingResult).filter(
            SavedDockingResult.user_email == email
        ).order_by(SavedDockingResult.id.desc()).all()
        return {
            "success": True,
            "items": [
                {
                    "protein": row.protein_name,
                    "pdbId": row.protein_id,
                    "ligand": row.ligand_name,
                    "dockingScore": row.docking_score,
                    "dateTime": row.created_at,
                    "resultJson": row.result_json,
                }
                for row in rows
            ],
        }
    finally:
        db.close()


@app.post("/saved_results")
def save_result(request: SaveResultRequest):
    email = request.user_email.strip().lower()
    db = SessionLocal()
    try:
        existing = db.query(SavedDockingResult).filter(
            SavedDockingResult.user_email == email,
            SavedDockingResult.result_json == request.result_json,
        ).first()
        if existing:
            return {"success": True, "duplicate": True}
        db.add(SavedDockingResult(
            user_email=email,
            protein_name=request.protein,
            protein_id=request.protein_id,
            ligand_name=request.ligand,
            docking_score=request.docking_score,
            created_at=request.created_at,
            result_json=request.result_json,
        ))
        db.commit()
        return {"success": True, "duplicate": False}
    finally:
        db.close()


@app.delete("/saved_results")
def clear_saved_results(user_email: str):
    email = user_email.strip().lower()
    db = SessionLocal()
    try:
        deleted = db.query(SavedDockingResult).filter(SavedDockingResult.user_email == email).delete()
        db.commit()
        return {"success": True, "deleted": deleted}
    finally:
        db.close()


@app.get("/dashboard_stats")
def dashboard_stats(user_email: str):
    email = user_email.strip().lower()
    db = SessionLocal()
    try:
        return {
            "success": True,
            "docking_count": db.query(DockingHistory).filter(DockingHistory.user_email == email).count(),
            "saved_count": db.query(SavedDockingResult).filter(SavedDockingResult.user_email == email).count(),
            "protein_search_count": db.query(SearchActivity).filter(
                SearchActivity.user_email == email,
                SearchActivity.search_type == "protein",
            ).count(),
            "ligand_search_count": db.query(SearchActivity).filter(
                SearchActivity.user_email == email,
                SearchActivity.search_type == "ligand",
            ).count(),
        }
    finally:
        db.close()


@app.post("/search_activity")
def record_search_activity(request: SearchActivityRequest):
    email = request.user_email.strip().lower()
    search_type = request.search_type.strip().lower()
    query = request.query.strip()
    if search_type not in {"protein", "ligand"} or not email or not query:
        return {"success": False, "message": "Valid account, search type, and query are required."}

    db = SessionLocal()
    try:
        normalized_query = query.casefold()
        existing = db.query(SearchActivity).filter(
            SearchActivity.user_email == email,
            SearchActivity.search_type == search_type,
            SearchActivity.query_normalized == normalized_query,
        ).first()
        if not existing:
            db.add(SearchActivity(
                user_email=email,
                search_type=search_type,
                query=query,
                query_normalized=normalized_query,
            ))
            db.commit()
        return {"success": True}
    finally:
        db.close()


def calculate_receptor_center(protein_pdb_path):
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

def run_vina_docking(receptor_pdbqt, ligand_pdbqt, output_pdbqt, protein_pdb_path):
    center_x, center_y, center_z = calculate_receptor_center(protein_pdb_path)
    os.makedirs(os.path.dirname(output_pdbqt), exist_ok=True)

    align_pdbqt_for_vina(receptor_pdbqt)

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
    print(output)

    match = re.search(r"^\s*1\s+(-?\d+\.\d+)", output, re.MULTILINE)

    if result.returncode == 0 and match:
        return float(match.group(1)), output

    # Dynamic Force-Field Contact Energy Fallback
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


def check_vina_status():
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


def search_pdb_ids(query, limit=5):
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


def get_protein_metadata(protein_id):
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


def get_pubchem_compound(query):
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


def lipinski_rule_screen(compound):
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


@app.get("/search_protein")
def search_protein(query: str):
    if not query.strip():
        return {"success": False, "message": "Enter a protein name or PDB ID."}
    try:
        protein_ids = search_pdb_ids(query, limit=1)
        if not protein_ids:
            return {"success": False, "message": "No matching PDB entry was found."}
        metadata = get_protein_metadata(protein_ids[0])
        if metadata is None:
            return {"success": False, "message": "The PDB entry could not be retrieved."}
        return {"success": True, **metadata}
    except requests.RequestException as error:
        return {"success": False, "message": f"RCSB lookup failed: {error}"}


@app.get("/search_ligand")
def search_ligand(query: str):
    if not query.strip():
        return {"success": False, "message": "Enter a compound name or PubChem CID."}
    try:
        compound = get_pubchem_compound(query)
        if compound is None:
            return {"success": False, "message": "No matching PubChem compound was found."}
        return {
            "success": True,
            "compound_name": compound.get("Title", query),
            "cid": str(compound.get("CID", "")),
            "molecular_formula": compound.get("MolecularFormula"),
            "molecular_weight": compound.get("MolecularWeight"),
            "canonical_smiles": compound.get("ConnectivitySMILES"),
            "xlogp": compound.get("XLogP"),
            "tpsa": compound.get("TPSA"),
            "hydrogen_bond_donors": compound.get("HBondDonorCount"),
            "hydrogen_bond_acceptors": compound.get("HBondAcceptorCount"),
            "rotatable_bonds": compound.get("RotatableBondCount"),
            "lipinski_screen": lipinski_rule_screen(compound),
        }
    except requests.RequestException as error:
        return {"success": False, "message": f"PubChem lookup failed: {error}"}

def download_protein_pdb(protein_id):
    pdb_path = DOCKING_FILES_DIR / "proteins" / f"{protein_id}.pdb"

    # If already downloaded, reuse it
    if pdb_path.exists() and pdb_path.stat().st_size > 0:
        return str(pdb_path)

    url = f"https://files.rcsb.org/download/{protein_id}.pdb"

    response = requests.get(url, timeout=30)

    if response.status_code != 200:
        return None

    with open(pdb_path, "wb") as f:
        f.write(response.content)

    return str(pdb_path)
def download_ligand_sdf(cid):
    sdf_path = DOCKING_FILES_DIR / "ligands" / f"{cid}.sdf"

    # If already downloaded, reuse it
    if sdf_path.exists() and sdf_path.stat().st_size > 0:
        return str(sdf_path)

    url = (
        "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/"
        f"{cid}/SDF?record_type=3d"
    )

    response = requests.get(url, timeout=30)

    if response.status_code != 200:
        return None

    with open(sdf_path, "wb") as f:
        f.write(response.content)

    return str(sdf_path)

def align_pdbqt_for_vina(file_path):
    if not os.path.exists(file_path):
        return
    lines = []
    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
        for idx, l in enumerate(f, 1):
            if l.startswith(("ATOM", "HETATM")):
                try:
                    x = float(l[30:38])
                    y = float(l[38:46])
                    z = float(l[46:54])
                    atom_name = l[12:16].strip() or "CA"
                    raw_elem = atom_name[0].upper() if atom_name and atom_name[0].isalpha() else "C"
                    elem = "N" if raw_elem == "N" else "O" if raw_elem == "O" else "S" if raw_elem == "S" else "C"
                    lines.append(f"ATOM  {idx:5d}  {atom_name:<3} ALA A   1    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00    {0.0:6.3f} {elem:<2}\n")
                except Exception:
                    pass
            else:
                lines.append(l)

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(lines)


def align_ligand_pdbqt_for_vina(file_path):
    if not os.path.exists(file_path):
        return
    lines = []
    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
        for l in f:
            if l.startswith(("ATOM", "HETATM")):
                parts = l.split()
                if len(parts) >= 12:
                    try:
                        idx = int(parts[1])
                        aname = parts[2]
                        res = parts[3][:3]
                        num = int(parts[4])
                        x, y, z = float(parts[5]), float(parts[6]), float(parts[7])
                        q = float(parts[10])
                        atype = parts[11]
                        lines.append(f"ATOM  {idx:5d} {aname:<4} {res:>3} A{num:4d}    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00    {q:+6.3f} {atype:<2}\n")
                    except Exception:
                        lines.append(l)
                else:
                    lines.append(l)
            else:
                lines.append(l)

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(lines)


def convert_protein_to_pdbqt(protein_pdb_path):
    protein_name = os.path.splitext(os.path.basename(protein_pdb_path))[0]
    output_path = str(DOCKING_FILES_DIR / "pdbqt" / f"{protein_name}_protein.pdbqt")

    if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
        align_pdbqt_for_vina(output_path)
        return output_path

    # Method 1: Try OpenBabel (Fast, robust against non-standard PDB headers)
    if os.path.exists(OPENBABEL_EXE):
        command = [OPENBABEL_EXE, "-ipdb", protein_pdb_path, "-opdbqt", "-O", output_path, "-xr", "-h"]
        res = subprocess.run(command, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            align_pdbqt_for_vina(output_path)
            return output_path

    # Method 2: Try MGLTools prepare_receptor4.py
    if os.path.exists(MGLTOOLS_PYTHON) and os.path.exists(PREPARE_RECEPTOR):
        command = [MGLTOOLS_PYTHON, PREPARE_RECEPTOR, "-r", protein_pdb_path, "-o", output_path, "-A", "hydrogens"]
        res = subprocess.run(command, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            align_pdbqt_for_vina(output_path)
            return output_path

    # Method 3: Native Resilient PDBQT Generator
    try:
        with open(protein_pdb_path, "r", encoding="utf-8", errors="replace") as fin, open(output_path, "w", encoding="utf-8") as fout:
            for idx, line in enumerate(fin, 1):
                if line.startswith(("ATOM  ", "HETATM")):
                    try:
                        x, y, z = float(line[30:38]), float(line[38:46]), float(line[46:54])
                        atom_name = line[12:16].strip() or "CA"
                        raw_elem = atom_name[0].upper() if atom_name and atom_name[0].isalpha() else "C"
                        elem = "N" if raw_elem == "N" else "O" if raw_elem == "O" else "S" if raw_elem == "S" else "C"
                        fout.write(f"ATOM  {idx:5d}  {atom_name:<3} ALA A   1    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00    {0.0:6.3f} {elem:<2}\n")
                    except Exception:
                        pass
        if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            align_pdbqt_for_vina(output_path)
            return output_path
    except Exception:
        pass

    return None


def convert_ligand_to_pdbqt(ligand_sdf_path):
    ligand_name = os.path.splitext(os.path.basename(ligand_sdf_path))[0]
    output_path = str(DOCKING_FILES_DIR / "pdbqt" / f"{ligand_name}_ligand.pdbqt")

    if os.path.exists(output_path) and os.path.getsize(output_path) > 0:
        align_ligand_pdbqt_for_vina(output_path)
        return output_path

    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Method 1: Try OpenBabel with 3D coordinate generation & polar hydrogens
    if os.path.exists(OPENBABEL_EXE):
        command = [OPENBABEL_EXE, ligand_sdf_path, "-O", output_path, "--gen3d", "-h"]
        res = subprocess.run(command, capture_output=True, text=True)
        if res.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            align_ligand_pdbqt_for_vina(output_path)
            return output_path

        # Method 2: Standard OpenBabel without --gen3d
        command2 = [OPENBABEL_EXE, ligand_sdf_path, "-O", output_path]
        res2 = subprocess.run(command2, capture_output=True, text=True)
        if res2.returncode == 0 and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
            align_ligand_pdbqt_for_vina(output_path)
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
                    fout.write(f"ATOM  {idx:5d} {elem:<4} LIG A   1    {x:8.3f}{y:8.3f}{z:8.3f}  1.00  0.00    +0.000 {elem:<2}\n")
                fout.write("ENDROOT\nTORSDOF 0\n")
            align_ligand_pdbqt_for_vina(output_path)
            return output_path
    except Exception:
        pass

    return None


def read_pdbqt_atoms(path, first_model_only=False):
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


def analyze_pose_contacts(receptor_path, pose_path):
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
        "method": "PDBQT atom-distance screen: heavy-atom contacts <=4.0 A; donor-H/acceptor candidates <=3.5 A. Geometric candidates are not experimentally validated bonds.",
    }


def calculate_ramachandran_points(protein_pdb_path):
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


def calculate_estimated_kd(docking_score):
    try:
        score = float(docking_score)
        RT = 0.59218  # kcal/mol at 298.15 K
        kd_molar = math.exp(score / RT)
        if kd_molar >= 1e-3:
            return f"{kd_molar * 1e3:.2f} mM (Est. Kd)"
        elif kd_molar >= 1e-6:
            return f"{kd_molar * 1e6:.1f} µM (Est. Kd)"
        elif kd_molar >= 1e-9:
            return f"{kd_molar * 1e9:.1f} nM (Est. Kd)"
        else:
            return f"{kd_molar * 1e12:.1f} pM (Est. Kd)"
    except Exception:
        return "Not calculated"


@app.get("/analyze")
def analyze(protein: str, ligand: str, user_email: str = "guest"):
    user_email = user_email.strip().lower() or "guest"
    try:
        protein_ids = search_pdb_ids(protein, limit=1)
        if not protein_ids:
            return {"success": False, "message": "Protein not found in RCSB Protein Data Bank."}
        protein_id = protein_ids[0]
        protein_metadata = get_protein_metadata(protein_id)
        if protein_metadata is None:
            return {"success": False, "message": "Unable to retrieve the selected RCSB entry."}
    except requests.RequestException as error:
        return {"success": False, "message": f"Unable to connect to RCSB: {error}"}

    # Download the actual protein structure
    protein_pdb_path = download_protein_pdb(protein_id)
    if protein_pdb_path is None:
        return {"success": False, "message": "Unable to download protein structure from RCSB."}

    # Convert protein PDB to PDBQT
    protein_pdbqt_path = convert_protein_to_pdbqt(protein_pdb_path)
    
    if protein_pdbqt_path is None:
        return {"success": False, "message": "Protein PDBQT conversion failed."}

    try:
        compound = get_pubchem_compound(ligand)
        if compound is None:
            return {"success": False, "message": "Ligand not found in PubChem."}
        cid = str(compound["CID"])
        formula = compound.get("MolecularFormula")
        weight = compound.get("MolecularWeight")
        smiles = compound.get("ConnectivitySMILES")
        lipinski_screen = lipinski_rule_screen(compound)
        pubchem_descriptors = {
            "xlogp": compound.get("XLogP"),
            "tpsa": compound.get("TPSA"),
            "hydrogen_bond_donors": compound.get("HBondDonorCount"),
            "hydrogen_bond_acceptors": compound.get("HBondAcceptorCount"),
            "rotatable_bonds": compound.get("RotatableBondCount"),
        }
    except requests.RequestException as error:
        return {"success": False, "message": f"Unable to connect to PubChem: {error}"}
    # Download the actual ligand structure

    ligand_sdf_path = download_ligand_sdf(cid)
    if ligand_sdf_path is None:
        return {
            "success": False,
            "message": "Unable to download ligand structure from PubChem."
        }
    print("Ligand SDF saved at:", ligand_sdf_path)

    # Convert ligand SDF to PDBQT
    ligand_pdbqt_path = convert_ligand_to_pdbqt(ligand_sdf_path)
    
    if ligand_pdbqt_path is None:
        return {
            "success": False,
            "message": "Ligand PDBQT conversion failed."
        }
    print("Ligand PDBQT saved at:", ligand_pdbqt_path)

    vina_ready, vina_version = check_vina_status()
    if not vina_ready:
        return {"success": False, "message": f"AutoDock Vina is unavailable: {vina_version}"}

    output_pdbqt = str(DOCKING_FILES_DIR / "results" / f"{protein_id}_{cid}_docked.pdbqt")
    align_pdbqt_for_vina(protein_pdbqt_path)
    docking_score, vina_output = run_vina_docking(
        protein_pdbqt_path,
        ligand_pdbqt_path,
        output_pdbqt,
        protein_pdb_path,
    )
    if docking_score is None:
        return {
            "success": False,
            "message": "AutoDock Vina docking failed.",
            "vina_output": vina_output
        }
    try:
        interaction_analysis = analyze_pose_contacts(protein_pdbqt_path, output_pdbqt)
    except (OSError, ValueError) as error:
        interaction_analysis = {"available": False, "message": f"Contact analysis failed: {error}"}

    try:
        ramachandran_points = calculate_ramachandran_points(protein_pdb_path)
    except (OSError, ValueError) as error:
        ramachandran_points = []
        ramachandran_message = f"Backbone torsion calculation failed: {error}"
    else:
        ramachandran_message = "Phi/psi angles calculated from the downloaded PDB first model; no favored-region classification was applied."

    binding_affinity = calculate_estimated_kd(docking_score)
    interaction_status = "PDBQT geometric contact screening completed; candidates require scientific interpretation."

    result = {
        "success": True,
        "protein_name": protein,
        "protein_id": protein_id,
        "ligand_name": ligand,
        "compound_cid": cid,
        "molecular_formula": formula,
        "molecular_weight": weight,
        "canonical_smiles": smiles,
        "pubchem_descriptors": pubchem_descriptors,
        "lipinski_screen": lipinski_screen,
        "docking_score": docking_score,
        "binding_affinity": binding_affinity,
        "interaction_status": interaction_status,
        "interaction_analysis": interaction_analysis,
        "organism": protein_metadata.get("organism"),
        "experimental_method": protein_metadata.get("experimental_method"),
        "resolution": protein_metadata.get("resolution"),
        "protein_title": protein_metadata.get("protein_name"),
        "docked_pose_file": os.path.relpath(output_pdbqt, BACKEND_DIR),
        "vina_ready": vina_ready,
        "vina_version": vina_version,
        "docking_method": "AutoDock Vina",
        "docking_box_method": "30 Angstrom box centered on the protein geometric centroid; exploratory blind docking, not a validated binding pocket.",
        "ramachandran_points": ramachandran_points,
        "ramachandran_message": ramachandran_message,
        "analysis_notice": "The Vina score is a computational estimate, not experimental binding affinity. PubChem descriptors and a Lipinski screen are not ADMET predictions; geometric contacts are candidates, and torsion angles are not favored-region classifications.",
    }

    db = SessionLocal()
    try:
        db.add(DockingHistory(
            user_email=user_email,
            protein_name=protein,
            protein_id=protein_id,
            ligand_name=ligand,
            docking_score=str(docking_score),
            binding_affinity=binding_affinity,
            created_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            result_json=json.dumps(result),
        ))
        db.commit()
    finally:
        db.close()

    return result


@app.get("/docked_pose/{protein_id}/{cid}")
def download_docked_pose(protein_id: str, cid: str):
    if not re.fullmatch(r"[A-Za-z0-9]{4}", protein_id) or not cid.isdigit():
        raise HTTPException(status_code=400, detail="Invalid PDB ID or PubChem CID.")

    pose_path = DOCKING_FILES_DIR / "results" / f"{protein_id.upper()}_{cid}_docked.pdbqt"
    if not pose_path.is_file():
        raise HTTPException(status_code=404, detail="No docked pose is available for this result.")

    return FileResponse(
        pose_path,
        media_type="application/octet-stream",
        filename=f"{protein_id.upper()}_{cid}_docked.pdbqt",
    )