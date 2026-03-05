from sqlmodel import Session
from app.models.modelos import Configuracion


def seed_configuracion(session: Session):
    """Crea la configuración inicial del restaurante"""
    configuracion = Configuracion(
        ubicacion_restaurante="-17.78385516924051, -63.181791393108945",
        precio_km=2.0,
        precio_base=5.0
    )
    session.add(configuracion)
    session.commit()
    print("✓ Configuración creada")
