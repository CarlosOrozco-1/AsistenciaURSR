// src/app/layout/pages/splash/splash.ts
import { Component } from '@angular/core'; // Ya no necesitamos OnInit ni Router

@Component({
  selector: 'app-loading-overlay', // Cambiamos el selector para indicar su nuevo rol
  standalone: true,
  templateUrl: './splash.html',
  styleUrls: ['./splash.css']
})
export class Splash {} // Puedes renombrarla a LoadingOverlay si quieres ser más claro