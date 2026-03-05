from datetime import datetime
from pydantic import BaseModel, EmailStr


class DeliveryBase(BaseModel):
    nombre: str
    email: EmailStr
    ubicacion: str


class DeliveryCreate(DeliveryBase):
    password: str


class DeliveryUpdate(BaseModel):
    nombre: str | None = None
    email: EmailStr | None = None
    password: str | None = None
    ubicacion: str | None = None
    disponible: bool | None = None


class DeliveryResponse(DeliveryBase):
    id: int
    disponible: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
