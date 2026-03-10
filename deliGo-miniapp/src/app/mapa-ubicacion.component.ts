import {
  AfterViewInit,
  Component,
  OnDestroy,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { HttpClient } from '@angular/common/http';
import { environment } from '../environments/enviroment';
import { PedidoResponse } from './interface/pedidos.interface';

declare const L: any;

@Component({
  selector: 'app-mapa-ubicacion',
  standalone: true,
  imports: [CommonModule],
  template: `
    <main class="main">
      <div class="content">
        <div class="left-side">
          <div class="map-header">Mapa</div>
          <div id="map" class="map-container"></div>
        </div>
        <div class="divider" role="separator" aria-label="Divider"></div>
        <div class="right-side">
          <div class="map-footer">
            <button
              type="button"
              class="map-button"
              (click)="confirmarUbicacion()"
              [disabled]="cargando"
            >
              {{ cargando ? 'Guardando...' : 'Confirmar' }}
            </button>
          </div>
        </div>
      </div>
    </main>
  `,
  styles: [
    `
      .main {
        width: 100%;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: stretch;
        padding: 1rem;
        box-sizing: border-box;
        background-color: #ffffff;
      }

      .content {
        display: flex;
        flex-direction: column;
        width: 100%;
        max-width: 100%;
        height: 100vh;
        margin: 0;
      }

      .left-side {
        flex: 1 1 0;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }

      .right-side {
        flex: 0 0 auto;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .divider {
        height: 1px;
        width: 100%;
        background: #e0e0e0;
        margin: 0.75rem 0;
      }

      .map-header {
        font-weight: 600;
        margin-bottom: 0.5rem;
      }

      .map-container {
        flex: 1 1 auto;
        width: 100%;
        border-radius: 1rem;
        overflow: hidden;
      }

      .map-footer {
        width: 100%;
        display: flex;
        justify-content: center;
      }

      .map-button {
        border: none;
        border-radius: 999px;
        padding: 0.7rem 2.5rem;
        background: #4caf50;
        color: #ffffff;
        font-size: 0.9rem;
        font-weight: 600;
        cursor: pointer;
      }
    `,
  ],
})
export class MapaUbicacionComponent implements AfterViewInit, OnDestroy {
  private map: any;
  private marker: any;
  private chatId: string | null = null;
  cargando = false;

  constructor(
    private route: ActivatedRoute,
    private http: HttpClient,
    private router: Router
  ) {}

  ngAfterViewInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      this.chatId = params.get('chat_id');
    });

    const initialLat = -17.783855;
    const initialLng = -63.181791;

    this.map = L.map('map', {
      center: [initialLat, initialLng],
      zoom: 16,
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '',
    }).addTo(this.map);

    const setMarker = (lat: number, lng: number) => {
      if (this.marker) {
        this.marker.setLatLng([lat, lng]);
      } else {
        this.marker = L.marker([lat, lng], { draggable: true }).addTo(this.map);
      }
    };

    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const { latitude, longitude } = position.coords;
          this.map.setView([latitude, longitude], 17);
          setMarker(latitude, longitude);
        },
        () => {
          setMarker(initialLat, initialLng);
        }
      );
    } else {
      setMarker(initialLat, initialLng);
    }

    this.map.on('click', (e: any) => {
      setMarker(e.latlng.lat, e.latlng.lng);
    });
  }

  confirmarUbicacion(): void {
    if (!this.marker || !this.chatId) {
      return;
    }

    const latlng = this.marker.getLatLng();
    const ubicacion_entrega = `${latlng.lat},${latlng.lng}`;

    this.cargando = true;

    this.http
      .post<PedidoResponse>(`${environment.backendUrl}/pedidos/ubicacion`, {
        chat_id: this.chatId,
        ubicacion_entrega,
      })
      .subscribe({
        next: () => {
          this.cargando = false;
          this.router.navigate(['/']); // volver al inicio o donde prefieras
        },
        error: (err) => {
          this.cargando = false;
          console.error('Error actualizando ubicación de entrega', err);
        },
      });
  }

  ngOnDestroy(): void {
    if (this.map) {
      this.map.remove();
    }
  }
}

