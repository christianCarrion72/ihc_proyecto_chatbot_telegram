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