import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-app-shell',
  standalone: true,
  imports: [RouterOutlet], // ← Importa RouterOutlet para usar <router-outlet> en el HTML
  templateUrl: './app-shell.html',
  styleUrls: ['./app-shell.css'],
})
export class AppShell {
  // sin lógica por ahora
}
