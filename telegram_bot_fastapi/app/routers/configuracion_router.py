from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.core.database import get_session
from app.services.configuracion_service import ConfiguracionService
from app.schemas.configuracion_schema import ConfiguracionCreate, ConfiguracionUpdate, ConfiguracionResponse

router = APIRouter(
    prefix="/configuraciones",
    tags=["Configuraciones"]
)

@router.get("/first", response_model=ConfiguracionResponse)
def get_first_configuracion(db: Session = Depends(get_session)):
    """Obtener la primera configuración"""
    configuracion = ConfiguracionService.get_first(db)
    if not configuracion:
        raise HTTPException(status_code=404, detail="Configuración no encontrada")
    return configuracion

