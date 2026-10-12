# Devlog

## 2026-10-12 — Selector convertido en laboratorio de situaciones

- `level_select` ofrece una entrada por situación disponible (hoy: «Desmarque con presión»), sin candados ni bloqueos. La selección sigue guardándose en `GameProgress` como nivel actual en base 1: no se borraron ni reiniciaron datos existentes.
- `situation_definition.gd` (`SituationDefinition`, Resource tipado) y `situation_catalog.gd` (`SituationCatalog`, lista ordenada construida en código) concentran los parámetros que antes eran exports de `main.gd`. Añadir una situación futura consiste en añadir un constructor al catálogo.
- `main.gd` aplica la definición seleccionada al arrancar (`apply_selected_situation`). La máquina de estados, los contactos por distancia y todos los valores numéricos del loop quedan intactos.
- Interfaz: título «LABORATORIO», botones generados en un `VBoxContainer`, etiqueta de éxito «¡SITUACIÓN SUPERADA!».
- `AGENTS.md` apunta ahora a `docs/FOOTBALL_DESIGN.md` en lugar del inexistente `GAME_DESIGN.md`.

Verificado en esta iteración: revisión del diff completo, `git diff --check` sin errores, greps sin referencias obsoletas a botones/niveles, y equivalencia numérica de los valores del catálogo con los exports anteriores de `main.gd`. No se pudo ejecutar la carga headless: no hay un binario de Godot utilizable en la máquina. Queda pendiente el playtest manual.

## 2026-10-11 — Auditoría de continuidad

Se inspeccionó la estructura actual de Godot, scripts de gameplay, escenas, progreso y navegación. No se modificó código de gameplay, `GAME_DESIGN.md` ni `AGENTS.md`.

Hallazgos principales:

- Existe un laboratorio jugable de desmarque, pase, rival y pelota en `main.tscn`.
- Existe una Home, selector de niveles y persistencia mínima de desbloqueos, aunque los niveles disponibles reutilizan la misma escena y no aplican dificultad distinta en el código inspeccionado.
- La pelota y el rival ya son entidades separadas; la evaluación de pase también está aislada.
- El único cambio preexistente detectado al comenzar fue `export_presets.cfg` no rastreado.

Próximo lote recomendado: playtest manual y definición humana del papel del selector actual frente al futuro laboratorio/partido. Después, conectar una configuración mínima de nivel a los parámetros existentes antes de crear contenido adicional.

### 2026-10-12 — Corrección de advertencias en Ball

- **Problema:** Godot mostraba advertencias `SHADOWED_VARIABLE_BASE_CLASS` en los métodos `reset_at()` y `stop_at()` de `ball/ball.gd`, porque el parámetro `position` compartía nombre con una propiedad heredada de `Node2D`.
- **Solución:** Se renombró el parámetro a `target_position` en ambas funciones.
- **Impacto:** Corrección de nombres para eliminar las advertencias, sin intención de modificar el comportamiento de la pelota ni la física.
- **Verificación:** El laboratorio y el ciclo de fallo, reinicio, éxito y regreso al laboratorio funcionan en la prueba manual. No se realizó una nueva verificación automatizada.
