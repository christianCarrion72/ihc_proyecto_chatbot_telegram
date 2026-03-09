import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'deliGo-miniapp';
  chatId: string | null = null;
  nombreUsuario: string | null = null;

  constructor(private route: ActivatedRoute) {}

  ngOnInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      this.chatId = params.get('chat_id');
      this.nombreUsuario = params.get('nombre_usuario');
      console.log('chat_id:', this.chatId, 'nombre_usuario:', this.nombreUsuario);
    });
  }
}
