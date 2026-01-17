import jwt
from fastapi import HTTPException, Depends, Header
from dotenv import load_dotenv
import os

SECRET_KEY = os.getenv("SECRET_KEY", "this_will_act_as_secret_key_if_you_dont_set_env_variable")
ALGORITHM = os.getenv("ALGORITHM", "HS256")

def create_jwt(email: str):
    payload = {"email": email}
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token

def verify_token(Authorization: str = Header(None)):
    if Authorization is None:
        raise HTTPException(status_code=401, detail="Missing Authorization header")

    try:
        # Expecting: "Bearer <token>"
        # Authorization: 'Bearer llakjsdflasdjflmyfuckingtoken'
        token = Authorization.split(" ")[1]
        data = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return data   # returns {"username": "..."}
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")


