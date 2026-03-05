from turtle import title
from fastapi import FastAPI

app = FastAPI(title="Proyecto IHC - Chatbot")

@app.get("/")
def root():
    return {"message": "Hello World"}