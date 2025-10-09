// src/app/features/auth/registro/registro.ts
import { Component, inject, signal, DestroyRef } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormBuilder, Validators, ReactiveFormsModule, AbstractControl, ValidationErrors } from '@angular/forms';
import { NgIf } from '@angular/common';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

import { AuthService, RegisterEstudianteDto } from '../../../core/auth/auth.service';

// ⬇️ Angular Material (solo imports; no cambia tu lógica)
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-registro',
  standalone: true,
  imports: [
    ReactiveFormsModule, NgIf, RouterLink,
    MatCardModule, MatFormFieldModule, MatInputModule,
    MatSelectModule, MatButtonModule, MatIconModule, MatProgressSpinnerModule
  ],
  templateUrl: './registro.html',
  styleUrls: ['./registro.css']
})

export class RegistroComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);
  private destroyRef = inject(DestroyRef); // ← para auto-unsubscribe

  // estado UI
  loading = signal(false);
  apiError = signal<string | null>(null);

  //flag para mostrar/ocultar contraseña
  hide1 = true;
  hide2 = true;

  // Reactive Form con validaciones básicas
  form = this.fb.group({
    nombres: ['', [Validators.required, Validators.minLength(2)]],
    apellidos: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]],
    numeroCarnet: ['', [Validators.required, Validators.minLength(6)]],
    idCarrera: ['', [Validators.required]],         // lo convertimos a number en el submit
    contrasena: ['', [Validators.required, Validators.minLength(8)]],
    contrasena2: ['', [Validators.required]],         // confirmación (no se envía al API)
  }, { validators: [passwordsIgualesValidator] });

  get f() { return this.form.controls; }

  constructor() {
    // Limpia el error global apenas el usuario modifica el formulario
    this.form.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(() => {
        if (this.apiError()) this.apiError.set(null);
        // si quisieras, también podrías apagar loading al primer cambio:
        // if (this.loading()) this.loading.set(false);
      });
  }

  async submit() {
    this.apiError.set(null);
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    // Armar DTO exactamente con los nombres que espera el backend
    const dto: RegisterEstudianteDto = {
      nombres: this.f.nombres.value!.trim(),
      apellidos: this.f.apellidos.value!.trim(),
      email: this.f.email.value!.trim(),
      numeroCarnet: this.f.numeroCarnet.value!.trim(),
      idCarrera: Number(this.f.idCarrera.value),
      contrasena: this.f.contrasena.value!,
    };

    this.loading.set(true);

    this.auth.registerStudent(dto).subscribe({
      next: async () => {
        // Éxito: (en el Punto 3 mostraremos un mensaje antes de ir al login)
        await this.router.navigate(['/login'], { replaceUrl: true });
      },
      error: (err) => {
        // Importante: apagar loading también en error
        this.loading.set(false);

        // Mensaje del backend si existe; de lo contrario, genérico
        const msg = err?.error?.message || err?.message || 'Error al registrar. Intenta nuevamente.';
        this.apiError.set(msg);
        console.error('[RegistroComponent] register error:', err);
      },
      complete: () => {
        // Si hubo éxito, también apagamos loading aquí
        this.loading.set(false);
      }
    });
  }
}

/** Validator a nivel form: contrasena y contrasena2 deben coincidir */
function passwordsIgualesValidator(group: AbstractControl): ValidationErrors | null {
  const pass = group.get('contrasena')?.value;
  const pass2 = group.get('contrasena2')?.value;
  if (pass && pass2 && pass !== pass2) {
    return { passwordMismatch: true };
  }
  return null;
}
