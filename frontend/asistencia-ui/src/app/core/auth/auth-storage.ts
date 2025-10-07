import { Injectable } from '@angular/core';

const TOKEN_KEY = 'auth_token'; // cambia el nombre si usas otro

@Injectable({ providedIn: 'root' })
export class AuthStorage {
  getToken(): string | null { return localStorage.getItem(TOKEN_KEY); }
  setToken(token: string): void { localStorage.setItem(TOKEN_KEY, token); }
  clear(): void { localStorage.removeItem(TOKEN_KEY); }
  isAuthenticated(): boolean { return !!this.getToken(); }
}
