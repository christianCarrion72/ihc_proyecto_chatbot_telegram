from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.core.database import init_db
from app.core.cors import configuracion_cors

from app.routers.categoria_router import router as categoria_router
from app.routers.configuracion_router import router as configuracion_router
from app.routers.plato_router import router as plato_router
from app.routers.delivery_router import router as delivery_router
from app.routers.pedido_router import router as pedido_router
from app.routers.detalle_router import router as detalle_router
from app.routers.bot_router import router as bot_router




@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Initializing database...")
    init_db()
    yield
    print("Shutting down database...")

app = FastAPI(title="Proyecto IHC - Chatbot", lifespan=lifespan)
configuracion_cors(app)

@app.get("/")
def root():
    return {"message": "Hello World"}

app.include_router(bot_router)
app.include_router(categoria_router)
app.include_router(delivery_router)
app.include_router(pedido_router)
app.include_router(configuracion_router)
app.include_router(plato_router)
app.include_router(detalle_router)
