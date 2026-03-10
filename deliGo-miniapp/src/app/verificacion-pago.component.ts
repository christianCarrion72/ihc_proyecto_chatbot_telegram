import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';

@Component({
  selector: 'app-verificacion-pago',
  standalone: true,
  imports: [CommonModule],
  template: `
    <main class="main">
      <div class="content">
        <div class="left-side">
          <div class="verificacion-header">Verificación</div>
          <div class="verificacion-container">
            <div class="verificacion-icon">
              <span class="verificacion-check">&#10003;</span>
            </div>
            <div class="verificacion-text">
              Su pago fue realizado exitosamente!
            </div>
          </div>
        </div>
        <div class="divider" role="separator" aria-label="Divider"></div>
        <div class="right-side">
          <div class="verificacion-footer">
            <button
              type="button"
              class="verificacion-button"
              (click)="mandarUbicacion()"
            >
              Mandar Ubicacion
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
        align-items: center;
        padding-top: 1rem;
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

      .verificacion-header {
        align-self: flex-start;
        font-weight: 600;
        margin-bottom: 1.5rem;
      }

      .verificacion-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        flex: 1;
        gap: 1rem;
      }

      .verificacion-icon {
        width: 140px;
        height: 140px;
        border-radius: 50%;
        background-color: #4caf50;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .verificacion-check {
        color: #ffffff;
        font-size: 72px;
        line-height: 1;
      }

      .verificacion-text {
        font-size: 0.95rem;
        font-weight: 500;
      }

      .verificacion-footer {
        width: 100%;
        display: flex;
        justify-content: center;
      }

      .verificacion-button {
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
export class VerificacionPagoComponent {
  constructor(private router: Router) {}

  mandarUbicacion(): void {
    this.router.navigate(['/ubicacion'], {
      queryParamsHandling: 'preserve',
    });
  }
}
