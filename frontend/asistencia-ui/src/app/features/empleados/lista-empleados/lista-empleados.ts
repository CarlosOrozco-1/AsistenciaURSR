// src/app/features/empleados/lista-empleados/lista-empleados.ts
import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';
import { EmpleadosService, Empleado } from '../../../services/empleados';
import { CommonModule } from '@angular/common'; // Para usar *ngIf, *ngFor

@Component({
  selector: 'app-lista-empleados',
  standalone: true, // Lo marcamos como componente independiente
  imports: [CommonModule], // Importamos CommonModule para las directivas
  templateUrl: './lista-empleados.html', // Usamos tu nombre de archivo
  styleUrl: './lista-empleados.css'     // Usamos tu nombre de archivo
})
export class ListaEmpleados implements OnInit {

  // Usamos el símbolo $ como convención para indicar que esta variable es un Observable.
  public empleados$!: Observable<Empleado[]>;

  // Inyectamos nuestro servicio en el constructor para poder usarlo.
  constructor(private empleadosService: EmpleadosService) { }

  // ngOnInit es un método que se ejecuta automáticamente cuando el componente se inicia.
  ngOnInit(): void {
    // Llamamos a la función del servicio para obtener los empleados.
    this.empleados$ = this.empleadosService.getEmpleados();
  }
}