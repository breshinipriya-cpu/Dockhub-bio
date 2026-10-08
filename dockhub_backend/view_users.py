from database import SessionLocal
from models import User

db = SessionLocal()

users = db.query(User).all()

for user in users:
    print(
        f"ID: {user.id}, Name: {user.name}, Email: {user.email}"
    )

db.close()