// src/app/core/auth/auth.models.ts
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
  token?: string;   // si tu API lo retorna; si no, déjalo opcional
}
