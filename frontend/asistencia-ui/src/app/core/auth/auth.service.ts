// src/app/core/auth/auth.service.ts
import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { API_BASE_URL } from '../config/api-base-url.token';
import { AuthStorage } from './auth-storage';

/** ===== Tipos existentes (login) ===== */
export interface LoginDto {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  // agrega aquí otros campos si tu API los retorna (nombre, rol, etc.)
}

/** ===== NUEVO: Tipos para registro de estudiante ===== */
export interface RegisterEstudianteDto {
  nombres: string;
  apellidos: string;
  email: string;
  numeroCarnet: string;
  idCarrera: number;
  contrasena: string;
}

export interface RegisterEstudianteResponse {
  ok?: boolean;
  message?: string;
  token?: string; // si tu API llegara a devolver token en el registro
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private baseUrl = inject(API_BASE_URL);
  private storage = inject(AuthStorage);

  // Rutas existentes
  private readonly LOGIN_PATH = '/v1/auth/login';

  // ===== NUEVO: endpoint de registro de estudiante =====
  // Asegúrate que API_BASE_URL = "http://localhost:3000/api"
  // para que la URL final sea: http://localhost:3000/api/v1/regEstudiante/estudiante
  private readonly REGISTER_STUDENT_PATH = '/v1/regEstudiante/estudiante';

  /** POST login → devuelve token (y lo manejarás en el componente) */
  login(dto: LoginDto) {
    const url = `${this.baseUrl}${this.LOGIN_PATH}`;
    console.log('[AuthService] apiBase =', this.baseUrl, ' loginPath =', this.LOGIN_PATH, ' -> url =', url);
    return this.http.post<LoginResponse>(url, dto);
  }

  /** ===== NUEVO: POST registro público de estudiante ===== */
  registerStudent(dto: RegisterEstudianteDto) {
    const url = `${this.baseUrl}${this.REGISTER_STUDENT_PATH}`;
    console.log('[AuthService] register url =', url, ' dto =', dto);
    return this.http.post<RegisterEstudianteResponse>(url, dto);
  }

  /** Helpers para manejar el token centralizadamente */
  saveToken(token: string) { this.storage.setToken(token); }
  logout() { this.storage.clear(); }
  isAuthenticated() { return this.storage.isAuthenticated(); }
  getToken() { return this.storage.getToken(); }
}
