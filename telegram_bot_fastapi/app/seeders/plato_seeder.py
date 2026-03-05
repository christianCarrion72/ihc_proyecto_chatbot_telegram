from sqlmodel import Session
from app.models.modelos import Plato


def seed_platos(session: Session, categorias: list):
    """Crea los platos para cada categoría"""
    comidas = [
        "Hamburguesa clásica",
        "Pollo frito",
        "Sándwich de lomito",
        "Pasta carbonara",
        "Tacos mixtos",
        "Lasagna",
        "Salchipapa",
        "Churrasco",
        "Pizza personal",
        "Ensalada César"
    ]

    bebidas = [
        "Coca Cola",
        "Agua mineral",
        "Jugo de naranja",
        "Limonada",
        "Té helado",
        "Café americano",
        "Café latte",
        "Batido de chocolate",
        "Refresco de maracuyá",
        "Sprite"
    ]

    postres = [
        "Helado de vainilla",
        "Torta de chocolate",
        "Flan casero",
        "Brownie",
        "Cheesecake",
        "Gelatina",
        "Pie de limón",
        "Tres leches",
        "Cupcake",
        "Alfajor"
    ]

    precios_demo = {
        "Comidas": 25,
        "Bebidas": 8,
        "Postres": 12
    }

    # Crear platos
    for cat in categorias:
        if cat.nombre == "Comidas":
            lista = comidas
        elif cat.nombre == "Bebidas":
            lista = bebidas
        else:
            lista = postres

        for nombre_plato in lista:
            session.add(
                Plato(
                    nombre=nombre_plato,
                    precio_venta=precios_demo[cat.nombre],
                    categoria_id=cat.id,
                    url_imagen="https://cdn-icons-png.flaticon.com/128/566/566498.png"
                )
            )

    session.commit()
    print("✓ Platos creados")
