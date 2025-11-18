from pymongo import MongoClient
from dotenv import load_dotenv # To load environment variables
import os 

load_dotenv() # Load environment variables from .env file

MONGO_URI = os.getenv("MONGO_URI")

client = MongoClient(MONGO_URI)
db = client["waste_classifier_db"] # Database for waste classifier
history_collection = db["history"] # Collection to store prediction history i.e. table