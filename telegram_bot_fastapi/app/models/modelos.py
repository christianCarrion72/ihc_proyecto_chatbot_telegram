from datetime import datetime, timezone
from sqlmodel import SQLModel, Field, Relationship

class Delivery(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    nombre: str
    email: str
    password: str
    ubicacion: str
    disponible: bool = True
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)})

    pedidos: list["Pedido"] = Relationship(back_populates="delivery")


class Categoria(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    nombre: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)})

    platos: list["Plato"] = Relationship(back_populates="categoria")


class Plato(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    nombre: str
    precio_venta: float
    url_imagen: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)})

    categoria_id: int = Field(foreign_key="categoria.id")
    categoria: Categoria = Relationship(back_populates="platos")

    detalles: list["Detalle"] = Relationship(back_populates="plato")


class Pedido(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    total: float
    estado: str  # en local, en camino, entregado
    ubicacion_entrega: str
    precio_delivery: float
    chat_id: str
    nombre_usuario: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)})

    delivery_id: int | None = Field(default=None, foreign_key="delivery.id")

    delivery: Delivery | None = Relationship(back_populates="pedidos")

    detalles: list["Detalle"] = Relationship(back_populates="pedido")


#Tabla intermedia
class Detalle(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    cantidad: int
    observacion: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)})

    pedido_id: int = Field(foreign_key="pedido.id")
    plato_id: int = Field(foreign_key="plato.id")

    pedido: Pedido = Relationship(back_populates="detalles")
    plato: Plato = Relationship(back_populates="detalles")


class Configuracion(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    ubicacion_restaurante: str
    precio_km: float
    precio_base: float
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc), sa_column_kwargs={"onupdate": lambda: datetime.now(timezone.utc)})
