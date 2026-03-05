from datetime import datetime
from pydantic import BaseModel


class DetalleBase(BaseModel):
    cantidad: int
    observacion: str
    pedido_id: int
    plato_id: int


class DetalleCreate(DetalleBase):
    pass


class DetalleUpdate(BaseModel):
    cantidad: int | None = None
    observacion: str | None = None
    pedido_id: int | None = None
    plato_id: int | None = None


class DetalleResponse(DetalleBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
