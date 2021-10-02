import pathlib
from fastapi import FastAPI

app = FastAPI()

BASE_DIR = pathlib.Path(__file__).resolve().parent

MODEL_DIR = BASE_DIR.parent / 'models'
MODEL_PATH = MODEL_DIR / "exports/spam-sms/spam-model.h5"

@app.get("/")
def read_index():
    return {
        "hello": "world",
        "models_dir": MODEL_DIR.exists(),
        "model_path": MODEL_PATH.exists()
    }