import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-splash',
  standalone: true,
  templateUrl: './splash.html',
  styleUrls: ['./splash.css']
})
export class Splash implements OnInit {
  constructor(private router: Router) {}

  ngOnInit(): void {
    // Pequeña espera para “intro” y luego ir al login
    setTimeout(() => this.router.navigateByUrl('/login'), 3500);
  }
}
