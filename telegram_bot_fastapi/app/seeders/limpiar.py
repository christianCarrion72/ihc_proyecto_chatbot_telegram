from sqlmodel import SQLModel, Session, create_engine
from app.core.config import settings
from app.models.modelos import Delivery, Categoria, Plato, Pedido, Detalle, Configuracion

DATABASE_URL = settings.DATABASE_URL
engine = create_engine(DATABASE_URL)

def limpiar_bd():
    with Session(engine) as session:
        # Eliminar en orden inverso a las dependencias (FK)
        for table in reversed(SQLModel.metadata.sorted_tables):
            session.execute(table.delete())
        session.commit()
    print("Base de datos limpiada!")

if __name__ == "__main__":
    limpiar_bd()
