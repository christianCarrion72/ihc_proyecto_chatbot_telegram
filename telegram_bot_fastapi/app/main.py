from fastapi import FastAPI
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Initializing database...")
    init_db()
    yield
    print("Shutting down database...")

app = FastAPI(title="Proyecto IHC - Chatbot", lifespan=lifespan)

@app.get("/")
def root():
    return {"message": "Hello World"}