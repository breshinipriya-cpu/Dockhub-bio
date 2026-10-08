import os
import shutil
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent
DOCKING_FILES_DIR = BACKEND_DIR / "docking_files"

for directory in ("proteins", "ligands", "pdbqt", "results"):
    (DOCKING_FILES_DIR / directory).mkdir(parents=True, exist_ok=True)

# Helper to locate binaries with safe Windows fallbacks
def _resolve_binary(env_var: str, default_path: str) -> str:
    from_env = os.getenv(env_var)
    if from_env and os.path.exists(from_env):
        return from_env
    if os.path.exists(default_path):
        return default_path
    discovered = shutil.which(env_var.lower().replace("_exe", ""))
    if discovered:
        return discovered
    return default_path

VINA_EXE = _resolve_binary(
    "VINA_EXE",
    r"C:\Users\user.LAPTOP\OneDrive\Desktop\Cvina\vina.exe.exe",
)

MGLTOOLS_PYTHON = _resolve_binary(
    "MGLTOOLS_PYTHON",
    r"C:\Program Files (x86)\MGLTools-1.5.7\python.exe",
)

PREPARE_RECEPTOR = os.getenv(
    "PREPARE_RECEPTOR",
    r"C:\Program Files (x86)\MGLTools-1.5.7\Lib\site-packages\AutoDockTools\Utilities24\prepare_receptor4.py",
)

OPENBABEL_EXE = _resolve_binary(
    "OPENBABEL_EXE",
    r"C:\Users\user.LAPTOP\OneDrive\Desktop\OpenBabel-3.1.1\obabel.exe",
)

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./dockhub_users.db")
