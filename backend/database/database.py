from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv
import os

load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
client = AsyncIOMotorClient(MONGO_URI)

DB_NAME = "wastevision"

db = client[DB_NAME]
users_collection = db["users"]

print("[+] Connected to MongoDB")
