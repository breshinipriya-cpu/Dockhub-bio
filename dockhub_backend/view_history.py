from database import SessionLocal
from models import DockingHistory

db = SessionLocal()

history = db.query(DockingHistory).all()

for item in history:
    print(
        f"User: {item.user_email} | "
        f"Protein: {item.protein_name} | "
        f"Ligand: {item.ligand_name} | "
        f"Score: {item.docking_score} | "
        f"Date: {item.created_at}"
    )

db.close()