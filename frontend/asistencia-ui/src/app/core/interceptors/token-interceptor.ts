import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthStorage } from '../auth/auth-storage';

const AUTH_EXCLUDE = ['/v1/auth/login']; // rutas a omitir (ajusta si tu login es distinto)

export const tokenInterceptor: HttpInterceptorFn = (req, next) => {
  const storage = inject(AuthStorage);

  // No adjuntar token a endpoints excluidos
  if (AUTH_EXCLUDE.some(path => req.url.includes(path))) {
    return next(req);
  }

  const token = storage.getToken();
  if (!token) return next(req);

  const authReq = req.clone({
    setHeaders: { Authorization: `Bearer ${token}` }
  });

  return next(authReq);
};
