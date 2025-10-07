// src/app/core/auth/auth.service.ts
import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { API_BASE_URL } from '../config/api-base-url.token';
import { AuthStorage } from './auth-storage';

export interface LoginDto {
  usuario: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  // agrega aquí otros campos si tu API los retorna (nombre, rol, etc.)
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private baseUrl = inject(API_BASE_URL);
  private storage = inject(AuthStorage);

  // 🔧 AJUSTA esta ruta al endpoint real de tu backend
  private readonly LOGIN_PATH = '/auth/login';

  /** POST login → devuelve token (y lo manejarás en el componente) */
  login(dto: LoginDto) {
    return this.http.post<LoginResponse>(`${this.baseUrl}${this.LOGIN_PATH}`, dto);
  }

  /** Helpers para manejar el token centralizadamente */
  saveToken(token: string) { this.storage.setToken(token); }
  logout() { this.storage.clear(); }
  isAuthenticated() { return this.storage.isAuthenticated(); }
  getToken() { return this.storage.getToken(); }
}
