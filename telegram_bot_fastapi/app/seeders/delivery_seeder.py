from sqlmodel import Session
from app.models.modelos import Delivery


def seed_delivery(session: Session):
    """Crea 5 deliveries de ejemplo"""
    deliveries_data = [
        {
            "nombre": "Primer Delivery",
            "email": "delivery1@example.com",
            "password": "00000000",
            "ubicacion": "-17.78179532334912, -63.17222261216227", # Arenales
            "disponible": True
        },
        {
            "nombre": "Segundo Delivery",
            "email": "delivery2@example.com",
            "password": "00000000",
            "ubicacion": "-17.775093316805012, -63.19581532318543", #UAGRM
            "disponible": True
        },
    ]

    for delivery_data in deliveries_data:
        ihc = Delivery(**delivery_data)
        session.add(ihc)
    
    session.commit()
    print("✓ Deliveries creados")
