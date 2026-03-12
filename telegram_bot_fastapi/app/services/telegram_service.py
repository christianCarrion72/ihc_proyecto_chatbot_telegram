import httpx
from app.core.config import settings

BOT = settings.TELEGRAM_BOT
MINIAPP = settings.FRONTEND


async def enviar_mensaje(chat_id: int, text: str):
    async with httpx.AsyncClient() as client:
        await client.post(f"{BOT}/sendMessage", json={"chat_id": chat_id, "text": text, "parse_mode": "Markdown",})


async def abrir_app(chat_id: int, nombre_usuario: str):
    async with httpx.AsyncClient() as client:
        await client.post(
            f"{BOT}/sendMessage",
            json={
                "chat_id": chat_id,
                "text": "🍽️ Realiza tu pedido aqui:",
                "reply_markup": {
                    "inline_keyboard": [
                        [
                            {
                                "text": "DeliGo App",
                                "web_app": {
                                    "url": f"{MINIAPP}?chat_id={chat_id}&nombre_usuario={nombre_usuario}"
                                },
                            }
                        ]
                    ]
                },
            },
        )
        print("Url:", f"{MINIAPP}?chat_id={chat_id}&nombre_usuario={nombre_usuario}")


async def resumen_pedido(pedido):
    print("Pedido:", pedido)
    mensaje = "🧾 *Resumen de tu pedido:*\n\n"
    mensaje += f"*Estado del pedido:* {pedido.estado}\n"

    mensaje += f"*Cliente:* {pedido.nombre_usuario}\n"

    mensaje += "*Detalles:*\n"
    for detalle in pedido.detalles:
        mensaje += f"- {detalle.plato.nombre} x{detalle.cantidad}"
        if detalle.observacion:
            mensaje += f" (Obs: {detalle.observacion})"
        mensaje += "\n"

    mensaje += f"\n*Total:* Bs{pedido.total:.2f}"

    async with httpx.AsyncClient() as client:
        await client.post(
            f"{BOT}/sendMessage",
            json={
                "chat_id": int(pedido.chat_id),
                "text": mensaje,
                "parse_mode": "Markdown",
            },
        )


async def estado_pedido(pedido):
    mensaje = f"🚚 Tu pedido está: *{pedido.estado}*"
    async with httpx.AsyncClient() as client:
        await client.post(
            f"{BOT}/sendMessage",
            json={
                "chat_id": int(pedido.chat_id),
                "text": mensaje,
                "parse_mode": "Markdown",
            },
        )


async def enviar_ubicacion(chat_id: int, ubicacion_delibery: str):
    latitud, longitud = map(float, ubicacion_delibery.split(","))
    async with httpx.AsyncClient() as client:
        await client.post(
            f"{BOT}/sendLocation",
            json={
                "chat_id": chat_id,
                "latitude": latitud,
                "longitude": longitud,
            },
        )


async def motivo_cancelacion(pedido, motivo: str):
    mensaje = (
        "❌ Tu pedido fue *cancelado*.\n"
        f"Motivo: {motivo}"
    )
    async with httpx.AsyncClient() as client:
        await client.post(
            f"{BOT}/sendMessage",
            json={
                "chat_id": int(pedido.chat_id),
                "text": mensaje,
                "parse_mode": "Markdown",
            },
        )
