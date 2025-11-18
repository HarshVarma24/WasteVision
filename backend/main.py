from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import numpy as np
import tensorflow as tf
import io # For handling byte streams means we can read image bytes directly
import json
from database import history_collection

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    allow_origins=["*"],
)

model = tf.keras.model.loa_model("waste_classification_model.h5")

Classes = [
    "Metal","Glass","Biological","Paper",
    "Battery","Trash","Cardboard","Shoes",
    "Clothes","Plastic"
    ]
    
with open("utils/disposal_instructions.json", "r") as f:
    disposal_data = json.load(f)
    
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    content = await file.read() # Read the uploaded file
    img = Image.open(io.BytesIO(content)).resize((224, 224)) # Resize image to model's expected input size
    img_arr = np.array(img)/255.0 # Normalize the image in the range [0, 1]
    img_arr = np.expand_dims(img_arr, axis=0) # Add batch dimension like (1, 224, 224, 3) i.e. height, width, channels
    
    predictions = model.predict(img_arr)
    waste_type = Classes[np.argmax(predictions[0])]
    confidence = float(np.max(predictions[0])) * 100
    instructions = disposal_data.get(waste_type, "No instructions available.")
    
    history_collection.insert_one({
        "waste_type": waste_type,
        "confidence": confidence,
        "instructions": instructions
    })
    
    return{
        "waste_type": waste_type,
        "confidence": confidence,
        "instructions": instructions
    }
    
    @app.get("/history")
    async def get_history():
        history = list(history_collection.find({}, {"_id": 0}))
        return history