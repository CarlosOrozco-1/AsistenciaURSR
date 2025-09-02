// Config global: registramos Router y HttpClient aquí.
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(),   // <- necesario para que HttpClient funcione
    provideRouter(routes), // <- conecta el router con las rutas de arriba
  ],
};
