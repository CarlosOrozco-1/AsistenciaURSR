// src/app/app.ts
import { Component, signal, OnInit } from '@angular/core'; // 👈 Importamos OnInit
import { RouterOutlet, Router } from '@angular/router'; // 👈 Importamos Router

@Component({
  selector: 'app-root',
  standalone: true, // Asumo que es standalone aunque no lo indicaste, basándome en los imports
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App implements OnInit { // 👈 Implementamos OnInit
  protected readonly title = signal('asistencia-ui');

  // 1. Inyectamos el Router
  constructor(private router: Router) {} 

  // 2. Usamos el hook de inicio para el temporizador
  ngOnInit(): void {
    // Nota: Aunque el splash se oculta por tiempo, el router ya ha resuelto la ruta a /login
    // El objetivo es garantizar que el splash esté visible un tiempo mínimo profesional (3.5s)
    setTimeout(() => {
      this.hideInitialSplash();
    }, 3500); // Mantenemos 3500ms (3.5 segundos)
  }

  /**
   * Oculta el elemento splash inyectado directamente en el index.html
   */
  private hideInitialSplash(): void {
    const splashElement = document.getElementById('initial-splash');
    if (splashElement) {
      // Usamos la clase CSS para una transición suave (opacidad a 0)
      splashElement.classList.add('splash-hidden');
      
      // Opcional: Eliminar el elemento del DOM después de la transición 
      // (ej. 500ms, que es el tiempo que definimos para la transición en styles.css)
      setTimeout(() => {
         splashElement.remove();
      }, 500); 
    }
  }
}