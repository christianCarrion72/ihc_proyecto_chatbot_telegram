from sqlmodel import Session, select
from app.models.modelos import Categoria
from app.schemas.categoria_schema import CategoriaCreate, CategoriaUpdate

class CategoriaService:
    @staticmethod
    def get_all(db: Session):
        categorias = db.exec(select(Categoria)).all()
        return categorias

    @staticmethod
    def get_by_id(db: Session, categoria_id: int):
        categoria = db.get(Categoria, categoria_id)
        return categoria

    @staticmethod
    def create(db: Session, categoria: CategoriaCreate):
        db_categoria = Categoria(**categoria.model_dump())
        db.add(db_categoria)
        db.commit()
        db.refresh(db_categoria)
        return db_categoria

    @staticmethod
    def update(db: Session, categoria_id: int, categoria: CategoriaUpdate):
        db_categoria = db.get(Categoria, categoria_id)
        if not db_categoria:
            return None

        categoria_date = categoria.model_dump(exclude_unset=True)
        for key, value in categoria_date.items():
            setattr(db_categoria, key, value)

        db.add(db_categoria)
        db.commit()
        db.refresh(db_categoria)
        return db_categoria

    @staticmethod
    def delete(db: Session, categoria_id: int):
        db_categoria = db.get(Categoria, categoria_id)
        if not db_categoria:
            return None
        db.delete(db_categoria)
        db.commit()
        return db_categoria