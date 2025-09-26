import { Component, OnDestroy, OnInit } from '@angular/core';

// Angular Material para tarjetas, botones e íconos
import { MatCardModule }   from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule }   from '@angular/material/icon';

// RouterLink para que las tarjetas naveguen
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    RouterLink,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
  ],
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.css']
})
export class Dashboard implements OnInit, OnDestroy {

  fechaHoy = '—';
  private _tickId?: any;

  ngOnInit(): void {
    this.actualizarFecha();
    // this._tickId = setInterval(() => this.actualizarFecha(), 60_000);
  }

  ngOnDestroy(): void {
    if (this._tickId) clearInterval(this._tickId);
  }

  private actualizarFecha(): void {
    this.fechaHoy = new Date().toLocaleString('es-GT', {
      dateStyle: 'full',
      timeStyle: 'short',
    });
  }
}
