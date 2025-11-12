from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI()

class Contact(BaseModel):
    name: str
    relation: str
    avatarUrl: str

class User(BaseModel):
    id: str
    name: str
    avatarUrl: str
    contacts: List[Contact]

db = {}

@app.put("/users/{user_id}")
def update_user(user_id: str, user: User):
    db[user_id] = user
    return {"message": "User updated", "data": user}
