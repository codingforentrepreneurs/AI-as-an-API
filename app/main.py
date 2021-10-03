import pathlib
from fastapi import FastAPI
import json
from typing import Optional

from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences
from tensorflow.keras.preprocessing.text import tokenizer_from_json
import numpy as np

app = FastAPI()

BASE_DIR = pathlib.Path(__file__).resolve().parent

MODEL_DIR = BASE_DIR.parent / 'models'
MODEL_PATH = MODEL_DIR / "spam-sms/spam-model.h5"
TOKENIZER_PATH = MODEL_DIR / "spam-sms/spam-classifer-tokenizer.json"
METADATA_PATH = MODEL_DIR / "spam-sms/spam-classifer-metadata.json"


AI_MODEL = None
AI_TOKENIZER = None
labels_legend_inverted = {}
model_metadata = {}

import numpy as np

class NumpyEncoder(json.JSONEncoder):
    """ Special json encoder for numpy types """
    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        return json.JSONEncoder.default(self, obj)



def predict(text_str, max_words=280, max_sequence = 280):
    global AI_MODEL, AI_TOKENIZER, labels_legend_inverted
    tokenizer = AI_TOKENIZER
    model = AI_MODEL
    if not tokenizer:
        return None
    if model is None:
        return None
    sequences = tokenizer.texts_to_sequences([text_str])
    x_input = pad_sequences(sequences, maxlen=max_sequence)
    preds = model.predict(x_input)[0]
    top_pred_idx = np.argmax(preds)
    top_pred_val = preds[top_pred_idx]
    # print(y_output, top_y_index)
    # preds = y_output[top_y_index]
    labeled_preds = [{
        "label": f"{labels_legend_inverted[str(i)]}",
        "confidence": x,
        } for i, x in enumerate(preds)]
    data = {
        "predictions": labeled_preds,
        "top": {
            "label": labels_legend_inverted[str(top_pred_idx)],
            "confidence": top_pred_val
        }
    }
    result = json.dumps(data, cls=NumpyEncoder)
    return json.loads(result)


@app.on_event("startup")
def on_startup():
    global AI_MODEL, AI_TOKENIZER, labels_legend_inverted, model_metadata
    if MODEL_PATH.exists():
        AI_MODEL = load_model(MODEL_PATH)
    if TOKENIZER_PATH.exists():
        AI_TOKENIZER = tokenizer_from_json(TOKENIZER_PATH.read_text())
    if METADATA_PATH.exists():
        model_metadata = json.loads(METADATA_PATH.read_text())
        labels_legend_inverted = model_metadata.get('labels_legend_inverted')

@app.get("/")
def read_index(q:Optional[str]=None):
    query = q or "Hello world"
    return {
        "input": query,
        "results": predict(query),
    }