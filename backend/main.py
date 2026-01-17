from fastapi import FastAPI, UploadFile, File, Depends
from PIL import Image
import numpy as np
import tensorflow as tf
import io
import json
from tensorflow.keras.models import load_model
import tensorflow
from database.database import db, users_collection
from models.user import UserLogin, UserSignup
import jwt
from auth.tokens import create_jwt, verify_token
from fastapi.concurrency import run_in_threadpool


app = FastAPI()

model = load_model("waste_classifier.keras", compile=False)

Classes = ['battery',
 'biological',
 'cardboard',
 'clothes',
 'glass',
 'metal',
 'paper',
 'plastic',
 'shoes',
 'trash']

# Load instructions JSON
with open("utils/disposal_instructions.json", "r") as f:
    disposal_data = json.load(f)

@app.post("/signup")
async def signup(user: UserSignup):
    existing_user = await users_collection.find_one({"email": user.email})
    if existing_user:
        return {"error": "User already exists"}
        
    user_dict = user.dict()
    await users_collection.insert_one(user_dict)
    
    return {"message": "User created successfully"}

@app.post("/login")
async def login(user: UserLogin):
    # the below line opens database and checks if the value entered by user on login exists
    # in our database. If it does, it returns the user data. Otherwise it returns None
    existing_user = await users_collection.find_one({"email": user.email})
    
    # if user does not exist in our database, it will simply return this error message
    if existing_user == None:
        return {"error": "User does not exist"}
    
    # Checks if password is invalid, if it is, it returns this error message   
    if existing_user["password"] != user.password:
        return {"error": "Incorrect password"}
    
    # If both username and password are correct, it returns this message
    return {"message": "Login successful", "token": create_jwt(user.email), "name": existing_user["name"]
}

@app.get("/testapi")
async def test_api():
    return {"message": "API is working"}

@app.get("/verifylogin")
def get_current_user(data: dict = Depends(verify_token)):
    return {"message": f"Hello, {data['email']}! Your token is valid."}

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    content = await file.read()

    img = Image.open(io.BytesIO(content)).resize((128, 128))
    img_arr = np.array(img) 
    img_arr = np.expand_dims(img_arr, axis=0)
    print(img_arr.shape)

    predictions = await run_in_threadpool(model.predict, img_arr)

    waste_type = Classes[np.argmax(predictions)]
    confidence = float(np.max(predictions)) * 100
    instructions = disposal_data.get(waste_type, "No instructions available.")

    return {
        "waste_type": waste_type,
        "confidence": confidence,
        }
