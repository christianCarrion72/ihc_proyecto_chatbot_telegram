from datetime import datetime
from pydantic import BaseModel

class CategoriaBase(BaseModel):
    nombre: str

class CategoriaCreate(CategoriaBase):
    pass

class CategoriaUpdate(BaseModel):
    nombre: str | None = None

class CategoriaResponse(CategoriaBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True