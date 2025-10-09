// src/app/app.routes.ts

import { Routes } from '@angular/router';

// Rutas existentes (features de prueba)
import { ListaClientesComponent } from './features/clientes/lista-clientes/lista-clientes';
import { ListaEmpleados } from './features/empleados/lista-empleados/lista-empleados';

// Shell (layout contenedor con router-outlet) SOLO para rutas privadas
import { AppShell } from './layout/shell/app-shell/app-shell';

export const routes: Routes = [
  // --- Rutas PÚBLICAS (fuera del Shell) ---
  
  // 1. Cambiamos la redirección de 'intro' a 'login'
  { path: '', pathMatch: 'full', redirectTo: 'login' }, 

  // 2. ELIMINAMOS LA RUTA DEL COMPONENTE SPLASH
  // {
  //   path: 'intro',
  //   loadComponent: () => import('./layout/pages/splash/splash').then(m => m.Splash),
  // },

  // Login (pública, fuera del shell)
  {
    path: 'login',
    loadComponent: () => import('./features/auth/login/login').then(m => m.LoginComponent),
    // Más adelante le agregamos un guard "guest" para evitar ver login si ya hay sesión.
  },
      // Registro de estudiante (pública, fuera del shell)
      {path: 'registro', loadComponent: () => import('./features/auth/registro/registro').then(m => m.RegistroComponent)},

  // --- Rutas PRIVADAS (dentro del Shell) ---
  {
    path: '',
    component: AppShell,
    // Más adelante: canMatch: [authGuard]  <-- cuando te pase el guard
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./features/dashboard/dashboard').then(m => m.Dashboard)
      },
      { path: 'clientes', component: ListaClientesComponent },
      { path: 'empleados', component: ListaEmpleados },
    ],
  },

  // Errores / extra
  { path: 'forbidden', loadComponent: () => import('./layout/pages/forbidden/forbidden').then(m => m.Forbidden) },
  { path: 'not-found', loadComponent: () => import('./layout/pages/not-found/not-found').then(m => m.NotFound) },
  { path: '**', redirectTo: 'not-found' },
];