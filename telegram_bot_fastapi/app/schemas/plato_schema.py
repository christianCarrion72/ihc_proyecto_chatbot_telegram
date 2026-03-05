from datetime import datetime
from pydantic import BaseModel


class PlatoBase(BaseModel):
    nombre: str
    precio_venta: float
    url_imagen: str
    categoria_id: int


class PlatoCreate(PlatoBase):
    pass


class PlatoUpdate(BaseModel):
    nombre: str | None = None
    precio_venta: float | None = None
    url_imagen: str | None = None
    categoria_id: int | None = None


class PlatoResponse(PlatoBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
