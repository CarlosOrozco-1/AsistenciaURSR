// src/app/features/auth/login/login.ts
import { Component, inject } from '@angular/core';
import { Router, ActivatedRoute, RouterLink } from '@angular/router'; // 👈 agrega RouterLink
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';

import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
// import { CarouselComponent } from '../../../shared/components/carousel/carousel'; // (no se usa en login ahora)

import { AuthService } from '../../../core/auth/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    RouterLink,              // 👈 necesario para routerLink en el template
    MatCardModule, 
    MatFormFieldModule, 
    MatInputModule, 
    MatButtonModule, 
    MatIconModule,
    // CarouselComponent,    // si luego lo usas, descomenta y añade aquí
  ],
  templateUrl: './login.html',
  styleUrls: ['./login.css']
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);

  loading = false;
  hide = true;

  form = this.fb.group({
    usuario: ['', [Validators.required]],
    password: ['', [Validators.required, Validators.minLength(4)]],
  });

  submit() {
    if (this.form.invalid) return;
    this.loading = true;

    const dto = {
      email: this.form.value.usuario!,
      password: this.form.value.password!,
    };

    console.log('[LoginComponent] submit dto =', dto);

    this.auth.login(dto as any).subscribe({
      next: (resp: any) => {
        if (resp?.token) {
          this.auth.saveToken(resp.token);
        } else if (resp?.access_token) {
          this.auth.saveToken(resp.access_token);
        } else if (resp?.data?.token) {
          this.auth.saveToken(resp.data.token);
        } else {
          alert('No se encontró el token en la respuesta.');
          this.loading = false;
          return;
        }

        const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') || '/dashboard';
        this.router.navigateByUrl(returnUrl);
      },
      error: (err) => {
        this.loading = false;
        console.error('[LoginComponent] login error', err.status, err.error);
        alert(err?.error?.message || 'Error al iniciar sesión');
      }
    });
  }

  // (Opcional) Si prefieres navegar desde TS en lugar de routerLink en el template:
  // goToRegister() {
  //   this.router.navigate(['/registro']);
  // }
}
