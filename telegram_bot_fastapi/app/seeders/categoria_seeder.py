from sqlmodel import Session
from app.models.modelos import Categoria


def seed_categorias(session: Session):
    """Crea las categorías de productos"""
    categorias_nombres = ["Comidas", "Bebidas", "Postres"]

    categorias = []
    for nombre in categorias_nombres:
        cat = Categoria(nombre=nombre)
        session.add(cat)
        categorias.append(cat)

    session.commit()
    print("✓ Categorías creadas")
    return categorias
