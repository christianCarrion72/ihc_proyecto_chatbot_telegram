from fastapi import APIRouter, Request, Depends
from sqlmodel import Session
from app.core.database import get_session
from app.services.pedido_service import PedidoService
from app.services.telegram_service import abrir_app, enviar_mensaje, enviar_ubicacion

router = APIRouter(tags=["Telegram Bot"])


@router.post("/webhook")
async def telegram_webhook(request: Request, db: Session = Depends(get_session)):

    data = await request.json()

    if "message" in data:
        chat_id = data["message"]["chat"]["id"]
        nombre_usuario = data["message"]["from"]["first_name"]
        texto = data["message"].get("text", "").lower()

        if texto == "/iniciar":
            await abrir_app(chat_id, nombre_usuario)
            
        if texto == "/ubicacion_pedido":
            await _ubicacion_pedido(db, chat_id)

    return {"ok": True}


async def _ubicacion_pedido(db: Session, chat_id: int):
    ubicacion = PedidoService.get_ubicacion_pedido(db, str(chat_id))
    if ubicacion:
        await enviar_ubicacion(chat_id, ubicacion)
    else:
        await enviar_mensaje(chat_id, "No tenes pedidos registrados")

