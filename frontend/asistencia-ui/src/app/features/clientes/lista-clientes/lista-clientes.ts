// Componente standalone que lista los clientes desde tu backend.
// Usa ClienteService (HTTP) y un paginador simple con limit/offset.

import { Component, OnInit, inject } from '@angular/core';
// CommonModule: *ngIf, *ngFor, etc.
import { CommonModule } from '@angular/common';
// FormsModule: para [(ngModel)] en el selector de "registros por página"
import { FormsModule } from '@angular/forms';

// Importamos el service que creaste para hablar con la API
import { ClienteService, Cliente } from '../../../services/cliente';

@Component({
  selector: 'app-lista-clientes',
  // Standalone = no necesitas declararlo en un módulo
  standalone: true,
  // Módulos que este componente necesita
  imports: [CommonModule, FormsModule],
  // Vista y estilos del componente
  templateUrl: './lista-clientes.html',
  styleUrls: ['./lista-clientes.css']
})
export class ListaClientesComponent implements OnInit {
  // Inyectamos el servicio con la función inject (Angular moderno)
  private clienteSrv = inject(ClienteService);

  // Estado de la vista
  rows: Cliente[] = []; // filas que vienen del backend
  total = 0;            // total de registros (para paginar)
  limit = 5;            // cuántos registros por página
  offset = 0;           // desplazamiento (página actual * limit)
  loading = false;      // para mostrar "Cargando…"
  error = '';           // mensaje de error (si ocurre)

  // Al cargar el componente, traemos la primera página
  ngOnInit(): void {
    this.cargar();
  }

  // Llama al backend: GET /api/dev/CLIENTE?limit=&offset=
  cargar(): void {
    this.loading = true;
    this.error = '';

    this.clienteSrv.listarClientes(this.limit, this.offset).subscribe({
      next: (res) => {
        // Guardamos las filas y el total para el paginador
        this.rows = res.rows;
        this.total = res.total;
        this.loading = false;
      },
      error: (err) => {
        // Si el backend devolvió { error: '...' }, mostramos ese texto
        this.error = err?.error?.error || 'Error al cargar clientes';
        this.loading = false;
      }
    });
  }

  // Botón "Anterior": restamos limit al offset sin bajar de 0
  prev(): void {
    if (this.offset > 0) {
      this.offset = Math.max(0, this.offset - this.limit);
      this.cargar();
    }
  }

  // Botón "Siguiente": avanzamos mientras no pasemos el total
  next(): void {
    if (this.offset + this.limit < this.total) {
      this.offset += this.limit;
      this.cargar();
    }
  }
}
