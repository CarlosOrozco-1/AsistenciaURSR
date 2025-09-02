// src/app/services/cliente.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Cliente {
  ID_CLIENTE: number;
  NOMBRE: string;
  IDENTIFICACION: string;
  TELEFONO: string;
}

export interface DevListResponse<T> {
  table: string;
  total: number;
  limit: number;
  offset: number;
  rows: T[];
}

@Injectable({ providedIn: 'root' })
export class ClienteService {
  private base = environment.apiBase;

  constructor(private http: HttpClient) {}

  listarClientes(limit = 10, offset = 0): Observable<DevListResponse<Cliente>> {
    const params = new HttpParams()
      .set('limit', limit)
      .set('offset', offset);
    return this.http.get<DevListResponse<Cliente>>(`${this.base}/dev/CLIENTE`, { params });
  }

  crearCliente(input: { nombre: string; identificacion: string; telefono: string }): Observable<Cliente> {
    const body = {
      NOMBRE: input.nombre,
      IDENTIFICACION: input.identificacion,
      TELEFONO: input.telefono,
    };
    return this.http.post<Cliente>(`${this.base}/cliente`, body);
  }
}
