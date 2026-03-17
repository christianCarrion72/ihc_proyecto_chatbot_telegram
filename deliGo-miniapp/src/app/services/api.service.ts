import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/enviroment';
import {
  Categoria,
  Plato,
  DetalleParaPedidoPayload,
  PedidoCompletoPayload,
  PedidoResponse,
} from '../interface/pedidos.interface';

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  constructor(private http: HttpClient) {}

  getPlatos(): Observable<Plato[]> {
    return this.http.get<Plato[]>(`${environment.backendUrl}/platos/`);
  }

  getCategorias(): Observable<Categoria[]> {
    return this.http.get<Categoria[]>(`${environment.backendUrl}/categorias/`);
  }

  crearPedidoCompleto(
    payload: PedidoCompletoPayload
  ): Observable<PedidoResponse> {
    return this.http.post<PedidoResponse>(
      `${environment.backendUrl}/pedidos/completo`,
      payload
    );
  }

  calcularTarifaDelivery(
    ubicacionEntrega: string
  ): Observable<{ tarifa: number }> {
    const url = `${environment.backendUrl}/deliveries/calcular-tarifa/${encodeURIComponent(
      ubicacionEntrega
    )}`;
    return this.http.get<{ tarifa: number }>(url);
  }

  getDeliveryMasCercano(): Observable<{ id: number }> {
    const url = `${environment.backendUrl}/deliveries/mas-cercano`;
    return this.http.get<{ id: number }>(url);
  }
}

