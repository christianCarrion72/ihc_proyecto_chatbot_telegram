from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.core.database import get_session
from app.services.pedido_service import PedidoService
from app.services.geocoding_service import reverse_geocode
from app.schemas.pedido_schema import (
    PedidoCreate,
    PedidoUpdate,
    PedidoResponse,
    PedidoCompletoCreate,
    PedidoUbicacionUpdate,
    PedidoCancelacion,
)

router = APIRouter(
    prefix="/pedidos",
    tags=["Pedidos"]
)

_direccion_cache: dict[int, str] = {}


@router.get("/", response_model=list[PedidoResponse])
async def get_pedidos(db: Session = Depends(get_session)):
    pedidos = PedidoService.get_all(db)
    responses: list[PedidoResponse] = []
    for p in pedidos:
        direccion = _direccion_cache.get(p.id)
        if direccion is None:
            direccion = await reverse_geocode(p.ubicacion_entrega)
            if direccion:
                _direccion_cache[p.id] = direccion
        responses.append(
            PedidoResponse(
                id=p.id,
                total=p.total,
                estado=p.estado,
                ubicacion_entrega=p.ubicacion_entrega,
                precio_delivery=p.precio_delivery,
                chat_id=p.chat_id,
                nombre_usuario=p.nombre_usuario,
                delivery_id=p.delivery_id,
                created_at=p.created_at,
                updated_at=p.updated_at,
                direccion_entrega=direccion,
            )
        )
    return responses


@router.get("/chat/{chat_id}", response_model=list[PedidoResponse])
async def get_pedidos_por_chat(chat_id: str, db: Session = Depends(get_session)):
    pedidos = PedidoService.get_by_chat_id(db, chat_id)
    responses: list[PedidoResponse] = []
    for p in pedidos:
        direccion = _direccion_cache.get(p.id)
        if direccion is None:
            direccion = await reverse_geocode(p.ubicacion_entrega)
            if direccion:
                _direccion_cache[p.id] = direccion
        responses.append(
            PedidoResponse(
                id=p.id,
                total=p.total,
                estado=p.estado,
                ubicacion_entrega=p.ubicacion_entrega,
                precio_delivery=p.precio_delivery,
                chat_id=p.chat_id,
                nombre_usuario=p.nombre_usuario,
                delivery_id=p.delivery_id,
                created_at=p.created_at,
                updated_at=p.updated_at,
                direccion_entrega=direccion,
            )
        )
    return responses


@router.get("/delivery/{delivery_id}", response_model=list[PedidoResponse])
async def get_pedidos_por_delivery(delivery_id: int, db: Session = Depends(get_session)):
    pedidos = PedidoService.get_by_delivery(db, delivery_id)
    responses: list[PedidoResponse] = []
    for p in pedidos:
        direccion = _direccion_cache.get(p.id)
        if direccion is None:
            direccion = await reverse_geocode(p.ubicacion_entrega)
            if direccion:
                _direccion_cache[p.id] = direccion
        responses.append(
            PedidoResponse(
                id=p.id,
                total=p.total,
                estado=p.estado,
                ubicacion_entrega=p.ubicacion_entrega,
                precio_delivery=p.precio_delivery,
                chat_id=p.chat_id,
                nombre_usuario=p.nombre_usuario,
                delivery_id=p.delivery_id,
                created_at=p.created_at,
                updated_at=p.updated_at,
                direccion_entrega=direccion,
            )
        )
    return responses


@router.get("/estado/{estado}", response_model=list[PedidoResponse])
async def get_pedidos_por_estado(estado: str, db: Session = Depends(get_session)):
    pedidos = PedidoService.get_by_estado(db, estado)
    responses: list[PedidoResponse] = []
    for p in pedidos:
        direccion = _direccion_cache.get(p.id)
        if direccion is None:
            direccion = await reverse_geocode(p.ubicacion_entrega)
            if direccion:
                _direccion_cache[p.id] = direccion
        responses.append(
            PedidoResponse(
                id=p.id,
                total=p.total,
                estado=p.estado,
                ubicacion_entrega=p.ubicacion_entrega,
                precio_delivery=p.precio_delivery,
                chat_id=p.chat_id,
                nombre_usuario=p.nombre_usuario,
                delivery_id=p.delivery_id,
                created_at=p.created_at,
                updated_at=p.updated_at,
                direccion_entrega=direccion,
            )
        )
    return responses


@router.get("/{pedido_id}", response_model=PedidoResponse)
async def get_pedido(pedido_id: int, db: Session = Depends(get_session)):
    pedido = PedidoService.get_by_id(db, pedido_id)
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    direccion = _direccion_cache.get(pedido.id)
    if direccion is None:
        direccion = await reverse_geocode(pedido.ubicacion_entrega)
        if direccion:
            _direccion_cache[pedido.id] = direccion
    return PedidoResponse(
        id=pedido.id,
        total=pedido.total,
        estado=pedido.estado,
        ubicacion_entrega=pedido.ubicacion_entrega,
        precio_delivery=pedido.precio_delivery,
        chat_id=pedido.chat_id,
        nombre_usuario=pedido.nombre_usuario,
        delivery_id=pedido.delivery_id,
        created_at=pedido.created_at,
        updated_at=pedido.updated_at,
        direccion_entrega=direccion,
    )


@router.post("/", response_model=PedidoResponse, status_code=201)
def create_pedido(pedido: PedidoCreate, db: Session = Depends(get_session)):
    return PedidoService.create(db, pedido)



@router.put("/{pedido_id}", response_model=PedidoResponse)
async def update_pedido(pedido_id: int, pedido: PedidoUpdate, db: Session = Depends(get_session)):
    db_pedido = await PedidoService.update(db, pedido_id, pedido)
    if not db_pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return db_pedido


@router.delete("/{pedido_id}", response_model=PedidoResponse)
def delete_pedido(pedido_id: int, db: Session = Depends(get_session)):
    db_pedido = PedidoService.delete(db, pedido_id)
    if not db_pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return db_pedido

@router.post("/completo", response_model=PedidoResponse, status_code=201)
async def crear_pedido_completo(pedido_completo: PedidoCompletoCreate, db: Session = Depends(get_session)):
    try:
        return await PedidoService.crear_pedido_completo(db, pedido_completo)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error al crear el pedido completo: {str(e)}")


@router.post("/ubicacion", response_model=PedidoResponse)
async def actualizar_ubicacion_pedido(
    data: PedidoUbicacionUpdate, db: Session = Depends(get_session)
):
    pedido = await PedidoService.actualizar_ubicacion_entrega(db, data)
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return pedido


@router.post("/{pedido_id}/cancelar", response_model=PedidoResponse)
async def cancelar_pedido(
    pedido_id: int,
    data: PedidoCancelacion,
    db: Session = Depends(get_session),
):
    pedido = await PedidoService.cancelar_pedido(db, pedido_id, data)
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return pedido
