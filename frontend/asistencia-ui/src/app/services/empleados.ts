import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

// Definimos una interfaz para nuestros datos, esto nos da autocompletado y seguridad.
export interface Empleado {
  ID: number;
  NOMBRE: string;
  PUESTO: string;
  SALARIO: number;
}

@Injectable({
  providedIn: 'root'
})
export class EmpleadosService {
  // La URL base de nuestra API. ¡Usa la IP de Tailscale de tu servidor local!
  private apiUrl = 'http://100.108.143.92:3000/api'; // endpoint de empleados con Tailscale

  constructor(private http: HttpClient) { }

  getEmpleados(): Observable<Empleado[]> {
    return this.http.get<Empleado[]>(`${this.apiUrl}/empleados`);
  }
}