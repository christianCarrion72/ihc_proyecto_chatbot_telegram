from datetime import datetime
from pydantic import BaseModel


class DetalleParaPedido(BaseModel):
    cantidad: int
    observacion: str
    plato_id: int


class PedidoBase(BaseModel):
    total: float
    estado: str
    ubicacion_entrega: str
    precio_delivery: float
    chat_id: str
    nombre_usuario: str


class PedidoCreate(PedidoBase):
    delivery_id: int | None = None


class PedidoCompletoCreate(BaseModel):
    total: float
    estado: str
    ubicacion_entrega: str
    precio_delivery: float
    chat_id: str
    nombre_usuario: str
    delivery_id: int | None = None
    detalles: list[DetalleParaPedido]


class PedidoUpdate(BaseModel):
    total: float | None = None
    estado: str | None = None
    ubicacion_entrega: str | None = None
    precio_delivery: float | None = None
    chat_id: str | None = None
    nombre_usuario: str | None = None
    delivery_id: int | None = None


class PedidoResponse(PedidoBase):
    id: int
    delivery_id: int | None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
