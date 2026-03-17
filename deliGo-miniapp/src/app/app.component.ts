import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import {
  Categoria,
  Plato,
  DetalleParaPedidoPayload,
  PedidoCompletoPayload,
  PedidoResponse,
} from './interface/pedidos.interface';
import { ApiService } from './services/api.service';
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
  totalBasePedido = 0;
  precioDelivery = 0;
  ubicacionEntrega: string | null = null;
  deliveryId: number | null = null;
  cargandoPedido = false;
  loadingPlatos = false;
  loadingCategorias = false;
  errorPlatos = '';
  errorCategorias = '';

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private api: ApiService
  ) {}

  ngOnInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      this.chatId = params.get('chat_id');
      this.nombreUsuario = params.get('nombre_usuario');
      console.log('chat_id:', this.chatId, 'nombre_usuario:', this.nombreUsuario);

      const resetParam = params.get('reset');
      if (resetParam === '1') {
        this.selectedCategoriaId = null;
        this.cantidades = {};
        this.observaciones = {};
        this.viendoResumen = false;
        this.viendoQr = false;
        this.totalBasePedido = 0;
        this.ultimoTotalPedido = 0;
        this.precioDelivery = 0;
        this.ubicacionEntrega = null;
        this.deliveryId = null;
        try {
          window.localStorage.removeItem('cantidadesDraft');
        } catch (e) {
          console.error('Error limpiando cantidades desde localStorage en reset', e);
        }
        return;
      }

      const tarifaParam = params.get('tarifa');
      const totalParam = params.get('total');
      const ubicacionParam = params.get('ubicacion');
      const deliveryIdParam = params.get('delivery_id');

      if (tarifaParam && totalParam && ubicacionParam && deliveryIdParam) {
        const tarifa = Number(tarifaParam);
        const totalBase = Number(totalParam);
        const deliveryId = Number(deliveryIdParam);

        if (!Number.isNaN(tarifa) && !Number.isNaN(totalBase) && !Number.isNaN(deliveryId)) {
          this.precioDelivery = tarifa;
          this.totalBasePedido = totalBase;
          this.ubicacionEntrega = ubicacionParam;
          this.deliveryId = deliveryId;
          this.ultimoTotalPedido = totalBase + tarifa;
          this.viendoResumen = false;
          this.viendoQr = true;
        }
      }

      try {
        const rawCantidades = window.localStorage.getItem('cantidadesDraft');
        if (rawCantidades) {
          const parsed = JSON.parse(rawCantidades) as { [key: string]: number };
          const restauradas: { [platoId: number]: number } = {};
          Object.keys(parsed).forEach((k) => {
            const id = Number(k);
            if (!Number.isNaN(id)) {
              restauradas[id] = parsed[k] ?? 0;
            }
          });
          this.cantidades = restauradas;
        }
      } catch (e) {
        console.error('Error restaurando cantidades desde localStorage', e);
      }
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
    this.selectedCategoriaId = null;
    this.viendoResumen = true;
  }

  confirmar(): void {
    this.totalBasePedido = this.totalPedido;
    if (!this.chatId || !this.nombreUsuario) {
      return;
    }

    try {
      window.localStorage.setItem('cantidadesDraft', JSON.stringify(this.cantidades));
    } catch (e) {
      console.error('Error guardando cantidades en localStorage', e);
    }

    this.router.navigate(['/ubicacion'], {
      queryParams: {
        chat_id: this.chatId,
        nombre_usuario: this.nombreUsuario,
        total: this.totalBasePedido,
      },
    });
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
      total: this.ultimoTotalPedido || this.totalPedido,
      estado: 'en local',
      ubicacion_entrega: this.ubicacionEntrega ?? 'por confirmar',
      precio_delivery: this.precioDelivery,
      chat_id: this.chatId as string,
      nombre_usuario: this.nombreUsuario as string,
      delivery_id: this.deliveryId,
      detalles,
    };
  }

  irAVerificacion(): void {
    const detalles = this.construirDetalles();

    if (!detalles.length || !this.chatId || !this.nombreUsuario) {
      console.error('No hay detalles de pedido o faltan datos de usuario');
      return;
    }

    const payload: PedidoCompletoPayload = this.construirPayload(detalles);

    this.cargandoPedido = true;

    this.api.crearPedidoCompleto(payload).subscribe({
      next: (pedido) => {
        this.cargandoPedido = false;
        this.ultimoTotalPedido = pedido.total;
        try {
          window.localStorage.removeItem('cantidadesDraft');
        } catch (e) {
          console.error('Error limpiando cantidadesDraft', e);
        }
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
    this.api
      .getPlatos()
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
    this.api
      .getCategorias()
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
