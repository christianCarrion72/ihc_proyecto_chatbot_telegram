from sqlmodel import Session, select
from app.models.modelos import Configuracion
from app.schemas.configuracion_schema import ConfiguracionCreate, ConfiguracionUpdate


class ConfiguracionService:
    
    @staticmethod
    def get_first(db: Session):
        configuracion = db.exec(select(Configuracion)).first()
        return configuracion
    
    @staticmethod
    def get_all(db: Session):
        configuraciones = db.exec(select(Configuracion)).all()
        return configuraciones

    @staticmethod
    def get_by_id(db: Session, configuracion_id: int):
        configuracion = db.get(Configuracion, configuracion_id)
        return configuracion

    @staticmethod
    def create(db: Session, configuracion: ConfiguracionCreate):
        db_configuracion = Configuracion(**configuracion.model_dump())
        db.add(db_configuracion)
        db.commit()
        db.refresh(db_configuracion)
        return db_configuracion

    @staticmethod
    def update(db: Session, configuracion_id: int, configuracion: ConfiguracionUpdate):
        db_configuracion = db.get(Configuracion, configuracion_id)
        if not db_configuracion:
            return None
        
        configuracion_data = configuracion.model_dump(exclude_unset=True)
        for key, value in configuracion_data.items():
            setattr(db_configuracion, key, value)
        
        db.add(db_configuracion)
        db.commit()
        db.refresh(db_configuracion)
        return db_configuracion

    @staticmethod
    def delete(db: Session, configuracion_id: int):
        db_configuracion = db.get(Configuracion, configuracion_id)
        if not db_configuracion:
            return None
        
        db.delete(db_configuracion)
        db.commit()
        return db_configuracion
