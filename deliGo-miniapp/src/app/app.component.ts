import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/enviroment';
import { Categoria, Plato } from './interface/pedidos.interface';



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
  cantidades: { [platoId: number]: number} = {};
  viendoResumen = false;

  constructor(private route: ActivatedRoute, private http: HttpClient) {}

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

  verOrden(): void {
    this.viendoResumen = true;
  }

  confirmar(): void {
    console.log('Pedido confirmado', {
      chatId: this.chatId,
      nombreUsuario: this.nombreUsuario,
      cantidades: this.cantidades,
    });
    this.viendoResumen = false;
  }

  seleccionarCategoria(id: number | null): void {
    this.selectedCategoriaId = id;
    if (this.viendoResumen) {
      this.viendoResumen = false;
    }
  }

  private loadPlatos(): void {
    this.http
      .get<Plato[]>(`${environment.backendUrl}/platos/`)
      .subscribe({
        next: (data) => (this.platos = data),
        error: (err) => console.error('Error cargando platos', err),
      });
  }

  private loadCategorias(): void {
    this.http
      .get<Categoria[]>(`${environment.backendUrl}/categorias/`)
      .subscribe({
        next: (data) => (this.categorias = data),
        error: (err) => console.error('Error cargando categorías', err),
      });
  }
}
