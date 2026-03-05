from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.core.database import get_session
from app.services.plato_service import PlatoService
from app.schemas.plato_schema import PlatoCreate, PlatoUpdate, PlatoResponse

router = APIRouter(
    prefix="/platos",
    tags=["Platos"]
)


@router.get("/", response_model=list[PlatoResponse])
def get_platos(db: Session = Depends(get_session)):
    return PlatoService.get_all(db)


@router.get("/categoria/{categoria_id}", response_model=list[PlatoResponse])
def get_platos_por_categoria(categoria_id: int, db: Session = Depends(get_session)):
    return PlatoService.get_by_categoria(db, categoria_id)


@router.get("/{plato_id}", response_model=PlatoResponse)
def get_plato(plato_id: int, db: Session = Depends(get_session)):
    plato = PlatoService.get_by_id(db, plato_id)
    if not plato:
        raise HTTPException(status_code=404, detail="Plato no encontrado")
    return plato


@router.post("/", response_model=PlatoResponse, status_code=201)
def create_plato(plato: PlatoCreate, db: Session = Depends(get_session)):
    return PlatoService.create(db, plato)


@router.put("/{plato_id}", response_model=PlatoResponse)
def update_plato(plato_id: int, plato: PlatoUpdate, db: Session = Depends(get_session)):
    db_plato = PlatoService.update(db, plato_id, plato)
    if not db_plato:
        raise HTTPException(status_code=404, detail="Plato no encontrado")
    return db_plato


@router.delete("/{plato_id}", response_model=PlatoResponse)
def delete_plato(plato_id: int, db: Session = Depends(get_session)):
    db_plato = PlatoService.delete(db, plato_id)
    if not db_plato:
        raise HTTPException(status_code=404, detail="Plato no encontrado")
    return db_plato
