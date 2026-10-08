from sqlalchemy import Column, Integer, String, Text, UniqueConstraint
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)


class DockingHistory(Base):
    __tablename__ = "docking_history"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, nullable=False)
    protein_name = Column(String, nullable=False)
    protein_id = Column(String, nullable=True)
    ligand_name = Column(String, nullable=False)
    docking_score = Column(String, nullable=False)
    binding_affinity = Column(String, nullable=False)
    created_at = Column(String, nullable=False)
    result_json = Column(Text, nullable=True)


class SavedDockingResult(Base):
    __tablename__ = "saved_docking_results"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, nullable=False, index=True)
    protein_name = Column(String, nullable=False)
    protein_id = Column(String, nullable=False)
    ligand_name = Column(String, nullable=False)
    docking_score = Column(String, nullable=False)
    created_at = Column(String, nullable=False)
    result_json = Column(Text, nullable=False)

    __table_args__ = (UniqueConstraint("user_email", "result_json", name="uq_saved_result_per_user"),)


class SearchActivity(Base):
    __tablename__ = "search_activity"

    id = Column(Integer, primary_key=True, index=True)
    user_email = Column(String, nullable=False, index=True)
    search_type = Column(String, nullable=False)
    query = Column(String, nullable=False)
    query_normalized = Column(String, nullable=False)

    __table_args__ = (UniqueConstraint("user_email", "search_type", "query_normalized", name="uq_search_per_user_type"),)


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, nullable=False, index=True)
    token = Column(String, unique=True, nullable=False, index=True)
    expires_at = Column(String, nullable=False)

