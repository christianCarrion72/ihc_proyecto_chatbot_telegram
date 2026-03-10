import { Routes } from '@angular/router';
import { AppComponent } from './app.component';

export const routes: Routes = [
  {
    path: '',
    component: AppComponent,
  },
  {
    path: 'verificacion',
    loadComponent: () =>
      import('./verificacion-pago.component').then(
        (m) => m.VerificacionPagoComponent
      ),
  },
  {
    path: 'ubicacion',
    loadComponent: () =>
      import('./mapa-ubicacion.component').then(
        (m) => m.MapaUbicacionComponent
      ),
  },
];
