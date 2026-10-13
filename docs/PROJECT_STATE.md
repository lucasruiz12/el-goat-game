# Estado técnico verificado

Auditoría: 2026-10-12. Describe lo inspeccionado en código; no sustituye una prueba manual de gameplay. El detalle de las pruebas automatizadas vive en `docs/TESTING.md`; el historial de cambios, en `docs/DEVLOG.md`.

## Estado de Git (2026-10-12)

- Rama: `master`, sincronizada con `origin`. `HEAD`: `b11cd03 feat: implement configurable holder movement for teammate during off-ball phase` (T3, commiteado y empujado por el desarrollador).
- Sin commitear en el worktree (T4, pendiente de validación y commit): `situation_evaluator.gd`, `tests/test_situation_evaluator.gd` y este cierre documental (`docs/DEVLOG.md`, `docs/PROJECT_STATE.md`, `docs/ROADMAP.md`).

## Escenas y sistemas presentes

| Área | Archivos | Estado verificado |
| --- | --- | --- |
| Inicio | `home/Home.tscn`, `home/home.gd` | Escena principal configurada. JUGAR abre el laboratorio. |
| Laboratorio | `level_select/LevelSelect.tscn`, `level_select/level_select.gd` | Una entrada por situación del catálogo, generada en código; sin bloqueos; marca ✓ de completada. |
| Situaciones | `situation_definition.gd`, `situation_catalog.gd` | Definición tipada por situación; catálogo en código; `main.gd` aplica la definición seleccionada al arrancar. Hoy: «Desmarque con presión». |
| Progreso | `game_progress.gd` | Persiste nivel actual, máximo desbloqueado y completado en `user://progress.cfg`; el laboratorio usa nivel actual (base 1, recortado al catálogo) y completadas. |
| Situación jugable | `main.tscn`, `main.gd` | Máquina de estados OFF_BALL → PASS → RESULT; contacto por distancia; rivales creados dinámicamente según `rival_count` (hoy 1). |
| Cancha | `field/Field.tscn`, `field/field.gd` | Mitad ofensiva visual; geometría y regiones normalizadas expuestas. |
| Jugador | `player/Player.tscn`, `player/player.gd` | `CharacterBody2D` con WASD y aceleración; sin colisiones físicas. |
| Compañero | `teammate/Teammate.tscn`, `teammate/teammate.gd` | Escena propia (extraída de `main.tscn`); origen del pase. Desde T3 puede desplazarse gradualmente hacia su punto de apoyo durante OFF_BALL (`move_toward`), configurable por situación; hoy `holder_shift_distance = 0` lo mantiene estático. |
| Rival | `rival/Rival.tscn`, `rival/rival.gd` | Nodos instanciados dinámicamente por `main.gd`; cada uno tiene un rol: `PRESSURE` persigue al objetivo (jugador en OFF_BALL, pelota en PASS) y `COVERAGE` se mantiene a 150 px de la amenaza (punto medio entre jugador y pelota) pero del lado del arco rival (centro consultado a `Field`). Ambos se desplazan con `move_toward`. |
| Pelota | `ball/Ball.tscn`, `ball/ball.gd` | Pase con desaceleración constante; contactos resueltos por distancia en `main.gd`. |
| Evaluación | `situation_evaluator.gd` | Destino de pase con error aleatorio, asumiendo un rival; `quality` calculado sin consumir. Desde T4, `evaluate_pass_lane` estima la calidad de la línea de pase contra una colección de rivales (distancia al segmento completo, determinista), todavía sin conectar a `main.gd`. |
| Pruebas | `tests/` | Runner propio headless (`run_tests.gd`), aserciones mínimas y tests de evaluador, catálogo y rival. Comando y reporte en `docs/TESTING.md`. |

## Limitaciones verificadas

- La cantidad de rivales es configurable por situación (`rival_count`); desde T2 existen roles básicos (`PRESSURE` y `COVERAGE`, con asignación local en `main.gd`) y un `PASS_LANE` previsto pero sin implementar; todavía no hay configuración de roles por situación ni evaluación de pases contra todos los rivales. Un solo compañero por situación.
- El desplazamiento del compañero es configurable (`holder_shift_distance`, hoy 0 = estático; apoyo hacia el jugador durante OFF_BALL); el pase es automático al agotarse el temporizador.
- Contactos por distancia, sin colisiones físicas ni rebotes.
- Los `quality` del evaluador (destino y línea de pase contra N rivales) no se consumen todavía; no hay evaluación separada de decisión, ejecución y resultado.
- Sin marcador, tiempo de partido, remate, audio ni animaciones.

## Comprobaciones y validaciones

Confirmado por el desarrollador:

- Suite automatizada después de T1: **28 comprobaciones, 0 fallas** (antes de T1: 26); la tarea de VS Code funciona.
- Validación manual de T1: la Situación 1 con 1 rival se comporta como antes; probada además con 2 y 6 rivales (con 6 la situación resulta muy difícil). La configuración quedó en 1 rival.
- Playtest manual de la Situación 1 tras la extracción del compañero.

Pendiente de confirmación:

- T4: corrida de la suite (debería informar 61 comprobaciones, 0 fallas). No requiere validación manual de juego: el método nuevo todavía no se consume.
- T2 y T3 (commiteados): validación de comportamiento sin reportar todavía. Para T2, prueba manual con `rival_count = 2` temporal (un `PRESSURE` persigue al jugador; un `COVERAGE` se ubica entre la amenaza —jugador y pelota— y el arco); para T3, elevar temporalmente `holder_shift_distance` para ver el apoyo del poseedor (con 0 el comportamiento debe ser el actual).
- Procedencia de la prueba manual descrita en la entrada «Corrección de advertencias en Ball» del DEVLOG (incluida en el commit `96a4826`, junto con el cambio en `ball/ball.gd`).

Conocido y no bloqueante (decisión del desarrollador): un warning de colisión de `Player` durante la ejecución local.

El binario de Godot en la máquina del asistente no es ejecutable: toda ejecución de pruebas y validación corre por cuenta del desarrollador.
