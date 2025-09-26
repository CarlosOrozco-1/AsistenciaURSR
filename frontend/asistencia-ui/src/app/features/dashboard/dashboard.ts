import { Component, OnDestroy, OnInit } from '@angular/core';

@Component({
  selector: 'app-dashboard',
  standalone: true,                 // ← importante: componente standalone
  imports: [],                      // ← por ahora no usamos pipes/módulos extras
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.css']    // ← ojo: es styleUrls (plural), no styleUrl
})
export class Dashboard implements OnInit, OnDestroy {

  /** Texto mostrado en el <time> del hero */
  fechaHoy = '—';

  /** Id del intervalo (si decides actualizar la hora periódicamente) */
  private _tickId?: any;

  ngOnInit(): void {
    // Set inicial (una sola vez)
    this.actualizarFecha();

    // (Opcional) refrescar cada minuto para mantener la hora “viva”
    // Descomenta si lo quieres activo en D-1
    // this._tickId = setInterval(() => this.actualizarFecha(), 60_000);
  }

  ngOnDestroy(): void {
    // Limpia el intervalo si lo activaste
    if (this._tickId) {
      clearInterval(this._tickId);
    }
  }

  /** Calcula y setea la fecha en formato es-GT */
  private actualizarFecha(): void {
    this.fechaHoy = new Date().toLocaleString('es-GT', {
      dateStyle: 'full',
      timeStyle: 'short',
    });
  }
}
