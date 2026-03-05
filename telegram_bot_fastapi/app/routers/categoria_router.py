from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.core.database import get_session
from app.services.categoria_service import CategoriaService
from app.schemas.categoria_schema import CategoriaCreate, CategoriaUpdate, CategoriaResponse

router = APIRouter(
    prefix="/categorias",
    tags=["Categorías"]
)

@router.get("/", response_model=list[CategoriaResponse])
def get_categorias(db: Session = Depends(get_session)):
    return CategoriaService.get_all(db)

@router.get("/{categoria_id}", response_model=CategoriaResponse)
def get_categoria(categoria_id: int, db: Session = Depends(get_session)):
    categoria = CategoriaService.get_by_id(db, categoria_id)
    if not categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")
    return categoria

@router.post("/", response_model=CategoriaResponse, status_code=201)
def create_categoria(categoria: CategoriaCreate, db: Session = Depends(get_session)):
    return CategoriaService.create(db, categoria)

@router.put("/{categoria_id}", response_model=CategoriaResponse)
def update_categoria(categoria_id: int, categoria: CategoriaUpdate, db: Session = Depends(get_session)):
    db_categoria = CategoriaService.update(db, categoria_id, categoria)
    if not db_categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")
    return db_categoria

@router.delete("/{categoria_id}", response_model=CategoriaResponse)
def delete_categoria(categoria_id: int, db: Session = Depends(get_session)):
    db_categoria = CategoriaService.delete(db, categoria_id)
    if not db_categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")
    return db_categoria