# Devlog

## 2026-10-12 — Punto de reanudación previo a compactación

- Commiteado por el desarrollador: infraestructura de pruebas (runner con descubrimiento automático y timeout genérico, `tests/run_tests.ps1`, `docs/TESTING.md`, tarea de VS Code) y sus archivos `.uid`.
- Sin commitear en el worktree: T1 completo (rivales en colección configurable) y su cierre documental.
- Confirmado por el desarrollador: suite pre-T1 con 26 comprobaciones en verde y tarea de VS Code operativa; playtest manual de la Situación 1 tras la extracción del compañero.
- Cierre de T1 confirmado por el desarrollador: suite post-T1 con 28 comprobaciones y 0 fallas, y validación manual con 1, 2 y 6 rivales (con 6 la situación resulta muy difícil); la configuración quedó en 1 rival. Warning de colisión de `Player` observado en ejecución local: conocido y no bloqueante por decisión del desarrollador.
- Próxima tarea propuesta, todavía no autorizada: T2 (roles de presión y cobertura).

## 2026-10-12 — T1: soporte para múltiples rivales

- `SituationDefinition` incorpora `rival_count` (por defecto 1) y «Desmarque con presión» lo fija explícitamente en 1.
- `main.gd` crea los rivales dinámicamente desde `Rival.tscn` y los administra en una colección: la presión y el contacto por distancia recorren la lista; se garantiza mínimo un rival porque el evaluador todavía modela uno solo.
- `main.tscn` ya no contiene el nodo Rival estático.
- Pruebas: fijado de `rival_count == 1` en el catálogo y en el valor por defecto de la definición (suite en 28 comprobaciones).

## 2026-10-12 — Infraestructura mínima de pruebas automatizadas

- `tests/run_tests.gd`: runner propio que extiende `SceneTree` y corre con Godot headless, sin frameworks; códigos de salida 0/1 en esta primera versión, hoy 0/1/2/3 (detalle vigente en `docs/TESTING.md`).
- `tests/test_case.gd`: aserciones mínimas (check, aproximación, punto en rectángulo).
- `tests/test_situation_evaluator.gd`: destino sin error = punto adelantado exacto; destino dentro de la zona segura con error extremo; calidad en [0, 1] y sensible a la distancia del rival. RNG sembrado para ser deterministas.
- `tests/test_situation_catalog.gd`: identidad de cada situación, recorte de índices fuera de rango y fijado de los parámetros exactos de la Situación 1 (protege el equilibrio actual).
- `tests/run_tests.ps1`: comando corto con ruta de Godot por parámetro o variable `GODOT`, propagación de código de salida (0/1/2/3).
- `docs/TESTING.md`: requisitos, comando, códigos de salida, formato de reporte y alcance.
- `AGENTS.md`: obligación de informar pruebas ejecutadas, fallidas, no ejecutadas y validaciones manuales pendientes.

Sin cambios en código de juego. La infraestructura todavía no se ejecutó: pendiente la primera corrida local con Godot 4.7.2 (no hay binario ejecutable en la máquina del asistente).

## 2026-10-12 — Selector convertido en laboratorio de situaciones

- `level_select` ofrece una entrada por situación disponible (hoy: «Desmarque con presión»), sin candados ni bloqueos. La selección sigue guardándose en `GameProgress` como nivel actual en base 1: no se borraron ni reiniciaron datos existentes.
- `situation_definition.gd` (`SituationDefinition`, Resource tipado) y `situation_catalog.gd` (`SituationCatalog`, lista ordenada construida en código) concentran los parámetros que antes eran exports de `main.gd`. Añadir una situación futura consiste en añadir un constructor al catálogo.
- `main.gd` aplica la definición seleccionada al arrancar (`apply_selected_situation`). La máquina de estados, los contactos por distancia y todos los valores numéricos del loop quedan intactos.
- Interfaz: título «LABORATORIO», botones generados en un `VBoxContainer`, etiqueta de éxito «¡SITUACIÓN SUPERADA!».
- `AGENTS.md` apunta ahora a `docs/FOOTBALL_DESIGN.md` en lugar del inexistente `GAME_DESIGN.md`.

Verificado en esta iteración: revisión del diff completo, `git diff --check` sin errores, greps sin referencias obsoletas a botones/niveles, y equivalencia numérica de los valores del catálogo con los exports anteriores de `main.gd`. No se pudo ejecutar la carga headless: no hay un binario de Godot utilizable en la máquina. Queda pendiente el playtest manual.

## 2026-10-12 — Corrección de advertencias en Ball

- **Problema:** Godot mostraba advertencias `SHADOWED_VARIABLE_BASE_CLASS` en los métodos `reset_at()` y `stop_at()` de `ball/ball.gd`, porque el parámetro `position` compartía nombre con una propiedad heredada de `Node2D`.
- **Solución:** Se renombró el parámetro a `target_position` en ambas funciones.
- **Impacto:** Corrección de nombres para eliminar las advertencias, sin intención de modificar el comportamiento de la pelota ni la física.
- **Verificación:** El laboratorio y el ciclo de fallo, reinicio, éxito y regreso al laboratorio funcionan en la prueba manual. No se realizó una nueva verificación automatizada.
- **Procedencia:** entrada incluida en el commit `96a4826` junto con el cambio en `ball/ball.gd`; la prueba manual descrita es una afirmación histórica pendiente de confirmación del desarrollador.

## 2026-10-11 — Auditoría de continuidad

Se inspeccionó la estructura actual de Godot, scripts de gameplay, escenas, progreso y navegación. No se modificó código de gameplay, `GAME_DESIGN.md` ni `AGENTS.md`.

Hallazgos principales:

- Existe un laboratorio jugable de desmarque, pase, rival y pelota en `main.tscn`.
- Existe una Home, selector de niveles y persistencia mínima de desbloqueos, aunque los niveles disponibles reutilizan la misma escena y no aplican dificultad distinta en el código inspeccionado.
- La pelota y el rival ya son entidades separadas; la evaluación de pase también está aislada.
- El único cambio preexistente detectado al comenzar fue `export_presets.cfg` no rastreado.

Próximo lote recomendado: playtest manual y definición humana del papel del selector actual frente al futuro laboratorio/partido. Después, conectar una configuración mínima de nivel a los parámetros existentes antes de crear contenido adicional.
