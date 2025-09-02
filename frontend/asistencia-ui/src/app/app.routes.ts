// src/app/app.routes.ts
import { Routes } from '@angular/router';
import { ListaClientesComponent } from './features/clientes/lista-clientes/lista-clientes';

export const routes: Routes = [
  // Página de listado
  { path: 'clientes', component: ListaClientesComponent },
  // Redirigir la raíz a /clientes
  { path: '', redirectTo: 'clientes', pathMatch: 'full' },
];
