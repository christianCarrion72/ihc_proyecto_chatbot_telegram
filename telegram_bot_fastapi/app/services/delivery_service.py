from sqlmodel import Session, select
from app.models.modelos import Delivery, Configuracion
from app.schemas.delivery_schema import DeliveryCreate, DeliveryUpdate
from math import radians, sin, cos, sqrt, atan2


class DeliveryService:
    @staticmethod
    def get_all(db: Session):
        deliveries = db.exec(select(Delivery)).all()
        return deliveries

    @staticmethod
    def get_by_id(db: Session, delivery_id: int):
        delivery = db.get(Delivery, delivery_id)
        return delivery

    @staticmethod
    def create(db: Session, delivery: DeliveryCreate):
        db_delivery = Delivery(**delivery.model_dump())
        db.add(db_delivery)
        db.commit()
        db.refresh(db_delivery)
        return db_delivery

    @staticmethod
    def update(db: Session, delivery_id: int, delivery: DeliveryUpdate):
        db_delivery = db.get(Delivery, delivery_id)
        if not db_delivery:
            return None
        
        delivery_data = delivery.model_dump(exclude_unset=True)
        for key, value in delivery_data.items():
            setattr(db_delivery, key, value)
        
        db.add(db_delivery)
        db.commit()
        db.refresh(db_delivery)
        return db_delivery

    @staticmethod
    def delete(db: Session, delivery_id: int):
        db_delivery = db.get(Delivery, delivery_id)
        if not db_delivery:
            return None
        
        db.delete(db_delivery)
        db.commit()
        return db_delivery

    @staticmethod
    def get_available(db: Session):
        deliveries = db.exec(select(Delivery).where(Delivery.disponible == True)).all()
        return deliveries

    @staticmethod
    def calcular_distancia_haversine(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        
        R = 6371.0
        
        lat1_rad = radians(lat1)
        lon1_rad = radians(lon1)
        lat2_rad = radians(lat2)
        lon2_rad = radians(lon2)
        
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = sin(dlat / 2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2)**2
        c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        distancia = R * c
        return distancia

    @staticmethod
    def get_delivery_mas_cercano(db: Session):
        configuracion = db.exec(select(Configuracion)).first()
        if not configuracion:
            raise ValueError("No se encontró configuración del restaurante")
        
        deliveries_disponibles = db.exec(select(Delivery).where(Delivery.disponible == True)).all()
        
        if not deliveries_disponibles:
            return None
        
        try:
            lat_entrega, lon_entrega = map(float, configuracion.ubicacion_restaurante.split(','))
        except ValueError:
            raise ValueError("Formato de ubicación del restaurante inválido")
        
        delivery_mas_cercano = None
        distancia_minima = float('inf')
        
        for delivery in deliveries_disponibles:
            try:
                lat_delivery, lon_delivery = map(float, delivery.ubicacion.split(','))
                distancia = DeliveryService.calcular_distancia_haversine(
                    lat_entrega, lon_entrega, lat_delivery, lon_delivery
                )
                
                if distancia < distancia_minima:
                    distancia_minima = distancia
                    delivery_mas_cercano = delivery
            except ValueError:
                continue
        
        return delivery_mas_cercano

    @staticmethod
    def calcular_tarifa_delivery(db: Session, ubicacion_entrega: str) -> float:
        configuracion = db.exec(select(Configuracion)).first()
        if not configuracion:
            raise ValueError("No se encontró configuración del restaurante")
        
        try:
            lat_restaurante, lon_restaurante = map(float, configuracion.ubicacion_restaurante.split(','))
        except ValueError:
            raise ValueError("Formato de ubicación del restaurante inválido")
        
        try:
            lat_entrega, lon_entrega = map(float, ubicacion_entrega.split(','))
        except ValueError:
            raise ValueError("Formato de ubicación de entrega inválido. Use: 'latitud,longitud'")
        
        distancia_km = DeliveryService.calcular_distancia_haversine(
            lat_restaurante, lon_restaurante, lat_entrega, lon_entrega
        )
        
        tarifa = (distancia_km * configuracion.precio_km) + configuracion.precio_base
        
        return tarifa
