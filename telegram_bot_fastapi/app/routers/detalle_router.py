from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.core.database import get_session
from app.services.detalle_service import DetalleService
from app.schemas.detalle_schema import DetalleCreate, DetalleUpdate, DetalleResponse

router = APIRouter(
    prefix="/detalles",
    tags=["Detalles"]
)


@router.get("/", response_model=list[DetalleResponse])
def get_detalles(db: Session = Depends(get_session)):
    return DetalleService.get_all(db)


@router.get("/pedido/{pedido_id}", response_model=list[DetalleResponse])
def get_detalles_por_pedido(pedido_id: int, db: Session = Depends(get_session)):
    return DetalleService.get_by_pedido(db, pedido_id)


@router.get("/{detalle_id}", response_model=DetalleResponse)
def get_detalle(detalle_id: int, db: Session = Depends(get_session)):
    detalle = DetalleService.get_by_id(db, detalle_id)
    if not detalle:
        raise HTTPException(status_code=404, detail="Detalle no encontrado")
    return detalle


@router.post("/", response_model=DetalleResponse, status_code=201)
def create_detalle(detalle: DetalleCreate, db: Session = Depends(get_session)):
    return DetalleService.create(db, detalle)


@router.put("/{detalle_id}", response_model=DetalleResponse)
def update_detalle(detalle_id: int, detalle: DetalleUpdate, db: Session = Depends(get_session)):
    db_detalle = DetalleService.update(db, detalle_id, detalle)
    if not db_detalle:
        raise HTTPException(status_code=404, detail="Detalle no encontrado")
    return db_detalle


@router.delete("/{detalle_id}", response_model=DetalleResponse)
def delete_detalle(detalle_id: int, db: Session = Depends(get_session)):
    db_detalle = DetalleService.delete(db, detalle_id)
    if not db_detalle:
        raise HTTPException(status_code=404, detail="Detalle no encontrado")
    return db_detalle
