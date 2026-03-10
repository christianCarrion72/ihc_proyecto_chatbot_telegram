from sqlmodel import Session, select, desc
from app.models.modelos import Pedido, Detalle, Configuracion
from app.schemas.pedido_schema import (
    PedidoCreate,
    PedidoUpdate,
    PedidoCompletoCreate,
    PedidoUbicacionUpdate,
)
from app.services import telegram_service


class PedidoService:
    @staticmethod
    def get_all(db: Session):
        pedidos = db.exec(select(Pedido)).all()
        return pedidos

    @staticmethod
    def get_by_id(db: Session, pedido_id: int):
        pedido = db.get(Pedido, pedido_id)
        return pedido

    @staticmethod
    def create(db: Session, pedido: PedidoCreate):
        db_pedido = Pedido(**pedido.model_dump())
        db.add(db_pedido)
        db.commit()
        db.refresh(db_pedido)
        return db_pedido

    @staticmethod
    async def update(db: Session, pedido_id: int, pedido: PedidoUpdate):
        db_pedido = db.get(Pedido, pedido_id)
        if not db_pedido:
            return None
        
        pedido_data = pedido.model_dump(exclude_unset=True)
        for key, value in pedido_data.items():
            setattr(db_pedido, key, value)
        
        db.add(db_pedido)
        db.commit()
        db.refresh(db_pedido)
        
        await telegram_service.estado_pedido(db_pedido)
        
        return db_pedido

    @staticmethod
    def delete(db: Session, pedido_id: int):
        db_pedido = db.get(Pedido, pedido_id)
        if not db_pedido:
            return None
        
        db.delete(db_pedido)
        db.commit()
        return db_pedido

    @staticmethod
    def get_by_chat_id(db: Session, chat_id: str):
        pedidos = db.exec(select(Pedido).where(Pedido.chat_id == chat_id)).all()
        return pedidos

    @staticmethod
    def get_by_delivery(db: Session, delivery_id: int):
        pedidos = db.exec(select(Pedido).where(Pedido.delivery_id == delivery_id)).all()
        return pedidos

    @staticmethod
    def get_by_estado(db: Session, estado: str):
        pedidos = db.exec(select(Pedido).where(Pedido.estado == estado)).all()
        return pedidos

    @staticmethod
    async def crear_pedido_completo(db: Session, pedido_completo: PedidoCompletoCreate):
        try:
            pedido_data = {
                "total": pedido_completo.total,
                "estado": pedido_completo.estado,
                "ubicacion_entrega": pedido_completo.ubicacion_entrega,
                "precio_delivery": pedido_completo.precio_delivery,
                "chat_id": pedido_completo.chat_id,
                "nombre_usuario": pedido_completo.nombre_usuario,
                "delivery_id": pedido_completo.delivery_id
            }
            db_pedido = Pedido(**pedido_data)
            db.add(db_pedido)
            db.flush()  
            
            
            if db_pedido.id is None:
                raise ValueError("No se pudo generar el ID del pedido")
            
            detalles_creados = []
            for detalle_data in pedido_completo.detalles:
                db_detalle = Detalle(
                    cantidad=detalle_data.cantidad,
                    observacion=detalle_data.observacion,
                    pedido_id=db_pedido.id,
                    plato_id=detalle_data.plato_id
                )
                db.add(db_detalle)
                detalles_creados.append(db_detalle)
            
            db.commit()
            db.refresh(db_pedido)
            
            for detalle in detalles_creados:
                db.refresh(detalle)
            
            await telegram_service.resumen_pedido(db_pedido)
            
            return db_pedido
        
        except Exception as e:
            db.rollback()
            raise e

    @staticmethod
    def get_ultimo_pedido(db: Session, chat_id: str):
        pedido = db.exec(
            select(Pedido)
            .where(Pedido.chat_id == chat_id)
            .order_by(desc(Pedido.created_at))
        ).first()
        return pedido
    
    @staticmethod
    def get_ubicacion_pedido(db: Session, chat_id: str):
        pedido = PedidoService.get_ultimo_pedido(db, chat_id)
        
        if not pedido:
            return None
        
        if pedido.estado.lower() == "en local":
            print("Obteniendo ubicación del restaurante")
            configuracion = db.exec(select(Configuracion)).first()
            if configuracion:
                return configuracion.ubicacion_restaurante
        
        if pedido.estado.lower() == "en camino":
            print("Obteniendo ubicación del delivery")
            if pedido.delivery:
                return pedido.delivery.ubicacion
        
        else:
            print("Obteniendo ubicación de entrega")
            return pedido.ubicacion_entrega
        
        return None

    @staticmethod
    async def actualizar_ubicacion_entrega(
        db: Session, data: PedidoUbicacionUpdate
    ):
        pedido = PedidoService.get_ultimo_pedido(db, data.chat_id)
        if not pedido:
            return None

        pedido.ubicacion_entrega = data.ubicacion_entrega
        db.add(pedido)
        db.commit()
        db.refresh(pedido)

        await telegram_service.estado_pedido(pedido)

        return pedido
