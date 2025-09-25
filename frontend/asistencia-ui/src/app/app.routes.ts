import { Routes } from '@angular/router';

// Rutas existentes de tus features de prueba
import { ListaClientesComponent } from './features/clientes/lista-clientes/lista-clientes';
import { ListaEmpleados } from './features/empleados/lista-empleados/lista-empleados';

// Shell (layout contenedor con router-outlet)
import { AppShell } from './layout/shell/app-shell/app-shell';

export const routes: Routes = [
  {
    path: '',
    component: AppShell,      // <- contenedor (toolbar/sidenav/router-outlet)
    children: [
      // Redirect raíz: cae a 'empleados' usando el Shell
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },

    {
      path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard/dashboard').then(m => m.Dashboard)
    },

      // Rutas privadas actuales (de prueba), renderizan dentro del Shell
      { path: 'clientes', component: ListaClientesComponent },
      { path: 'empleados', component: ListaEmpleados },

      // En el futuro aquí irán las rutas reales: dashboard, usuarios, etc.
      // { path: 'dashboard', loadComponent: () => import('./features/dashboard/dashboard').then(m => m.Dashboard) },
      // { path: 'usuarios', loadChildren: () => import('./features/usuarios/usuarios.routes').then(m => m.USUARIOS_ROUTES) },
    ],
  },

  // Rutas públicas y de error (las activaremos cuando existan los componentes)
  // { path: 'login', loadComponent: () => import('./features/auth/login/login').then(m => m.Login) },
  { path: 'forbidden', loadComponent: () => import('./layout/pages/forbidden/forbidden').then(m => m.Forbidden) }, // Página 403: acceso denegado (la usaremos más adelante con RoleGuard)
  {path: 'not-found', loadComponent: () => import('./layout/pages/not-found/not-found').then(m => m.NotFound)}, 
  { path: '**', loadComponent: () => import('./layout/pages/not-found/not-found').then(m => m.NotFound) }, // Catch-all 404: cualquier ruta no definida cae aquí
];
