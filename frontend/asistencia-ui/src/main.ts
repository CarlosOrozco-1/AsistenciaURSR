// src/main.ts

import 'zone.js'; // Requerido por Angular para NgZone (cambio de detección por defecto)

// Arranque de la app Angular (standalone)
import { bootstrapApplication } from '@angular/platform-browser';

// Carga la configuración global (router, http, etc.)
import { appConfig } from './app/app.config';

// IMPORTANTE: en tu estructura el root es "App", definido en src/app/app.ts
// No existe AppComponent ni app.component.ts
import { App } from './app/app';

// importar localización local
import { registerLocaleData } from '@angular/common';
import esGT from '@angular/common/locales/es-GT';
registerLocaleData(esGT);




// Bootstrap de la app con su configuración
bootstrapApplication(App, appConfig)
  .catch(err => console.error(err));
