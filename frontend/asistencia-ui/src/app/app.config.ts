// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { environment } from '../environments/environment';
import { API_BASE_URL } from './core/config/api-base-url.token';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { tokenInterceptor } from './core/interceptors/token-interceptor';
import { errorInterceptor } from './core/interceptors/error-interceptor';
import { LOCALE_ID } from '@angular/core';
import { MAT_DATE_LOCALE } from '@angular/material/core';
import { provideAnimations } from '@angular/platform-browser/animations';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([tokenInterceptor, errorInterceptor])),
    provideAnimations(),
    { provide: API_BASE_URL, useValue: environment.apiBase },
    { provide: LOCALE_ID, useValue: 'es-GT' },
    { provide: MAT_DATE_LOCALE, useValue: 'es-GT' },
  ]
};
