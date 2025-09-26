import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

// Angular Material (standalone)
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule }  from '@angular/material/button';
import { MatIconModule }    from '@angular/material/icon';

@Component({
  selector: 'app-app-shell',
  standalone: true,
  // Importamos Router y módulos de Material que usaremos en el template
  imports: [RouterOutlet, RouterLink, RouterLinkActive, MatToolbarModule, MatButtonModule, MatIconModule],
  templateUrl: './app-shell.html',
  styleUrls: ['./app-shell.css'],
})
export class AppShell {
  // Por ahora sin lógica; más adelante podemos leer el usuario y roles
}
