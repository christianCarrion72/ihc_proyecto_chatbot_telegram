export interface Plato {
  id: number;
  nombre: string;
  precio_venta: number;
  url_imagen: string;
  categoria_id: number;
}

export interface Categoria {
  id: number;
  nombre: string;
}

export interface DetalleParaPedidoPayload {
  cantidad: number;
  observacion: string;
  plato_id: number;
}

export interface PedidoCompletoPayload {
  total: number;
  estado: string;
  ubicacion_entrega: string;
  precio_delivery: number;
  chat_id: string;
  nombre_usuario: string;
  delivery_id: number | null;
  detalles: DetalleParaPedidoPayload[];
}

export interface PedidoResponse {
  id: number;
  total: number;
  estado: string;
  ubicacion_entrega: string;
  precio_delivery: number;
  chat_id: string;
  nombre_usuario: string;
  delivery_id: number | null;
  created_at: string;
  updated_at: string;
}
