import { Component, Input, AfterViewInit, OnDestroy, inject } from '@angular/core';
import { CommonModule, isPlatformBrowser } from '@angular/common';
import { PLATFORM_ID } from '@angular/core';

type Slide = { image: string; title?: string; subtitle?: string };

@Component({
  selector: 'app-carousel',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './carousel.html',
  styleUrls: ['./carousel.css']
})
export class CarouselComponent implements AfterViewInit, OnDestroy {
  private platformId = inject(PLATFORM_ID);
  private isBrowser = isPlatformBrowser(this.platformId);

  @Input() slides: Slide[] = [];

  current = 0;
  private timerId: any = null;

  ngAfterViewInit() {
    // 👇 Evita correr lógica de DOM/intervalos en SSR
    if (!this.isBrowser) return;

    // Si usas una librería que accede a window/document (p. ej. Swiper),
    // MUÉVELA AQUÍ dentro del if (this.isBrowser) o haz import dinámico:
    // const { Swiper } = await import('swiper');

    // Ejemplo autoplay simple sin librerías:
    this.timerId = setInterval(() => {
      this.current = (this.current + 1) % (this.slides?.length || 1);
    }, 4000);
  }

  ngOnDestroy() {
    if (this.timerId) clearInterval(this.timerId);
  }

  prev() { this.current = (this.current - 1 + this.slides.length) % this.slides.length; }
  next() { this.current = (this.current + 1) % this.slides.length; }
}
