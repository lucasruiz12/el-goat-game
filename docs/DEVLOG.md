# Devlog

## 2026-10-11 — Auditoría de continuidad

Se inspeccionó la estructura actual de Godot, scripts de gameplay, escenas, progreso y navegación. No se modificó código de gameplay, `GAME_DESIGN.md` ni `AGENTS.md`.

Hallazgos principales:

- Existe un laboratorio jugable de desmarque, pase, rival y pelota en `main.tscn`.
- Existe una Home, selector de niveles y persistencia mínima de desbloqueos, aunque los niveles disponibles reutilizan la misma escena y no aplican dificultad distinta en el código inspeccionado.
- La pelota y el rival ya son entidades separadas; la evaluación de pase también está aislada.
- El único cambio preexistente detectado al comenzar fue `export_presets.cfg` no rastreado.

Próximo lote recomendado: playtest manual y definición humana del papel del selector actual frente al futuro laboratorio/partido. Después, conectar una configuración mínima de nivel a los parámetros existentes antes de crear contenido adicional.
