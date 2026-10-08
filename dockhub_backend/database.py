from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import declarative_base, sessionmaker
from config import DATABASE_URL

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    Base.metadata.create_all(bind=engine)
    
    # Ensure migration columns for legacy SQLite tables
    try:
        history_columns = {column["name"] for column in inspect(engine).get_columns("docking_history")}
        if "result_json" not in history_columns or "protein_id" not in history_columns:
            with engine.begin() as connection:
                if "result_json" not in history_columns:
                    connection.execute(text("ALTER TABLE docking_history ADD COLUMN result_json TEXT"))
                if "protein_id" not in history_columns:
                    connection.execute(text("ALTER TABLE docking_history ADD COLUMN protein_id TEXT"))
    except Exception as e:
        print(f"Database schema check notice: {e}")