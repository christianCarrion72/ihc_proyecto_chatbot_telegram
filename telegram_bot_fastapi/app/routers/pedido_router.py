from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.core.database import get_session
from app.services.pedido_service import PedidoService
from app.schemas.pedido_schema import PedidoCreate, PedidoUpdate, PedidoResponse, PedidoCompletoCreate

router = APIRouter(
    prefix="/pedidos",
    tags=["Pedidos"]
)


@router.get("/", response_model=list[PedidoResponse])
def get_pedidos(db: Session = Depends(get_session)):
    return PedidoService.get_all(db)


@router.get("/chat/{chat_id}", response_model=list[PedidoResponse])
def get_pedidos_por_chat(chat_id: str, db: Session = Depends(get_session)):
    return PedidoService.get_by_chat_id(db, chat_id)


@router.get("/delivery/{delivery_id}", response_model=list[PedidoResponse])
def get_pedidos_por_delivery(delivery_id: int, db: Session = Depends(get_session)):
    return PedidoService.get_by_delivery(db, delivery_id)


@router.get("/estado/{estado}", response_model=list[PedidoResponse])
def get_pedidos_por_estado(estado: str, db: Session = Depends(get_session)):
    return PedidoService.get_by_estado(db, estado)


@router.get("/{pedido_id}", response_model=PedidoResponse)
def get_pedido(pedido_id: int, db: Session = Depends(get_session)):
    pedido = PedidoService.get_by_id(db, pedido_id)
    if not pedido:
        raise HTTPException(status_code=404, detail="Pedido no encontrado")
    return pedido


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

