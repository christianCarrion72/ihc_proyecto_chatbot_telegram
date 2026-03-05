from sqlmodel import Session
from app.core.database import engine
from app.seeders.configuracion_seeder import seed_configuracion
from app.seeders.delivery_seeder import seed_delivery
from app.seeders.categoria_seeder import seed_categorias
from app.seeders.plato_seeder import seed_platos


def run_seed():
    with Session(engine) as session:
        print("Iniciando seeders...")
        
        seed_configuracion(session)
        
        seed_delivery(session)
        
        categorias = seed_categorias(session)
        
        seed_platos(session, categorias)
        
        print("\nSeed completado =)")


if __name__ == "__main__":
    run_seed()
