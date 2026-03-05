from datetime import datetime
from pydantic import BaseModel


class ConfiguracionBase(BaseModel):
    ubicacion_restaurante: str
    precio_km: float
    precio_base: float


class ConfiguracionCreate(ConfiguracionBase):
    pass


class ConfiguracionUpdate(BaseModel):
    ubicacion_restaurante: str | None = None
    precio_km: float | None = None
    precio_base: float | None = None


class ConfiguracionResponse(ConfiguracionBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
