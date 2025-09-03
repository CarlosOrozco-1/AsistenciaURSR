// src/app/app.routes.ts
import { Routes } from '@angular/router';
// Mantenemos la importación de tu componente de clientes
import { ListaClientesComponent } from './features/clientes/lista-clientes/lista-clientes';
// Añadimos la importación de nuestro nuevo componente de empleados
import { ListaEmpleados } from './features/empleados/lista-empleados/lista-empleados';

export const routes: Routes = [
  // Tu ruta de clientes sigue existiendo
  { path: 'clientes', component: ListaClientesComponent },

  // Añadimos la nueva ruta para empleados
  { path: 'empleados', component: ListaEmpleados},

  // Cambiamos la redirección para que la página principal ahora sea la de empleados
  { path: '', redirectTo: 'empleados', pathMatch: 'full' },
];