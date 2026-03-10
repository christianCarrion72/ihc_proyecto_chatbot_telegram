import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/enviroment';
import {
  Categoria,
  Plato,
  DetalleParaPedidoPayload,
  PedidoCompletoPayload,
  PedidoResponse,
} from './interface/pedidos.interface';
import { retry } from 'rxjs';
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'deliGo-miniapp';
  chatId: string | null = null;
  nombreUsuario: string | null = null;
  platos: Plato[] = [];
  categorias: Categoria[] = [];
  selectedCategoriaId: number | null = null;
  cantidades: { [platoId: number]: number } = {};
  observaciones: { [platoId: number]: string } = {};
  viendoResumen = false;
  viendoQr = false;
  ultimoTotalPedido = 0;
  cargandoPedido = false;
  loadingPlatos = false;
  loadingCategorias = false;
  errorPlatos = '';
  errorCategorias = '';

  constructor(
    private route: ActivatedRoute,
    private http: HttpClient,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      this.chatId = params.get('chat_id');
      this.nombreUsuario = params.get('nombre_usuario');
      console.log('chat_id:', this.chatId, 'nombre_usuario:', this.nombreUsuario);
    });

    this.loadCategorias();
    this.loadPlatos();
  }

  getCantidad(platoId: number): number {
    return this.cantidades[platoId] ?? 0;
  }

  incrementar(platoId: number): void{
    const actual = this.cantidades[platoId] ?? 0;
    this.cantidades[platoId] = actual + 1;
  }

  decrementar(platoId: number): void {
    const actual = this.cantidades[platoId] ?? 0;
    const nuevo = actual - 1;
    this.cantidades[platoId] = nuevo < 0 ? 0 : nuevo;
  }

  get filteredPlatos(): Plato[] {
    if (!this.selectedCategoriaId) {
      return this.platos;
    }
    return this.platos.filter((plato) => plato.categoria_id === this.selectedCategoriaId);
  }

  get resumenPlatos(): Plato[] {
    return this.platos.filter((plato) => (this.cantidades[plato.id] ?? 0) > 0);
  }

  get totalPedido(): number {
    return this.resumenPlatos.reduce(
      (acc, plato) => acc + (this.cantidades[plato.id] ?? 0) * plato.precio_venta,
      0
    );
  }

  get qrUrl(): string {
    const data = encodeURIComponent(
      `DeliGo|monto=${this.ultimoTotalPedido}|chat=${this.chatId ?? ''}|nombre=${
        this.nombreUsuario ?? ''
      }`
    );
    return `https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=${data}`;
  }

  verOrden(): void {
    this.viendoResumen = true;
  }

  confirmar(): void {
    this.ultimoTotalPedido = this.totalPedido;
    this.viendoResumen = false;
    this.viendoQr = true;
  }

  private construirDetalles(): DetalleParaPedidoPayload[] {
    const detalles: DetalleParaPedidoPayload[] = this.resumenPlatos
      .map((plato) => {
        const cantidad = this.getCantidad(plato.id);
        if (cantidad <= 0) {
          return null;
        }
        return {
          cantidad,
          observacion: this.observaciones[plato.id] ?? '',
          plato_id: plato.id,
        } as DetalleParaPedidoPayload;
      })
      .filter((d): d is DetalleParaPedidoPayload => d !== null);

    return detalles;
  }

  private construirPayload(detalles: DetalleParaPedidoPayload[]): PedidoCompletoPayload {
    return {
      total: this.totalPedido,
      estado: 'en local',
      ubicacion_entrega: 'por confirmar',
      precio_delivery: 0,
      chat_id: this.chatId as string,
      nombre_usuario: this.nombreUsuario as string,
      delivery_id: null,
      detalles,
    };
  }

  irAVerificacion(): void {
    const detalles = this.construirDetalles();

    if (!detalles.length || !this.chatId || !this.nombreUsuario) {
      return;
    }

    const payload: PedidoCompletoPayload = this.construirPayload(detalles);

    this.cargandoPedido = true;

    this.http
      .post<PedidoResponse>(`${environment.backendUrl}/pedidos/completo`, payload)
      .subscribe({
        next: (pedido) => {
          this.cargandoPedido = false;
          this.ultimoTotalPedido = pedido.total;
          this.router.navigate(['/verificacion'], {
            queryParamsHandling: 'preserve',
          });
        },
        error: (err) => {
          this.cargandoPedido = false;
          console.error('Error creando pedido completo', err);
        },
      });
  }

  seleccionarCategoria(id: number | null): void {
    this.selectedCategoriaId = id;
    if (this.viendoResumen) {
      this.viendoResumen = false;
    }
    if (this.viendoQr) {
      this.viendoQr = false;
    }
  }

  private loadPlatos(): void {
    this.loadingPlatos = true;
    this.errorPlatos = '';
    this.http
      .get<Plato[]>(`${environment.backendUrl}/platos/`)
      .pipe(retry(2))
      .subscribe({
        next: (data) => {
          this.platos = data;
          this.loadingPlatos = false;
        },
        error: (err) => {
          this.loadingPlatos = false;
          this.errorPlatos = 'No se pudieron cargar los platos';
          console.error('Error cargando platos', err);
        },
      });
  }

  private loadCategorias(): void {
    this.loadingCategorias = true;
    this.errorCategorias = '';
    this.http
      .get<Categoria[]>(`${environment.backendUrl}/categorias/`)
      .pipe(retry(2))
      .subscribe({
        next: (data) => {
          this.categorias = data;
          this.loadingCategorias = false;
        },
        error: (err) => {
          this.loadingCategorias = false;
          this.errorCategorias = 'No se pudieron cargar las categorías';
          console.error('Error cargando categorías', err);
        },
      });
  }
}
