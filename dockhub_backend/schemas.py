from pydantic import BaseModel

class SignupRequest(BaseModel):
    name: str
    email: str
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class SaveResultRequest(BaseModel):
    user_email: str
    protein: str
    protein_id: str
    ligand: str
    docking_score: str
    created_at: str
    result_json: str


class SearchActivityRequest(BaseModel):
    user_email: str
    search_type: str
    query: str


class ForgotPasswordRequest(BaseModel):
    email: str


class ResetPasswordRequest(BaseModel):
    email: str
    token: str
    new_password: str

