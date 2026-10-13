# Estado técnico verificado

Auditoría: 2026-10-12. Describe lo inspeccionado en código; no sustituye una prueba manual de gameplay. El detalle de las pruebas automatizadas vive en `docs/TESTING.md`; el historial de cambios, en `docs/DEVLOG.md`.

## Estado de Git (2026-10-12, previo a compactación manual)

- Rama: `master`, sincronizada con `origin`. `HEAD`: `02b6c2a feat: add evaluate_pass_lane method to assess pass line quality against rivals` (T4, commiteado y empujado por el desarrollador).
- Sin commitear en el worktree (T5, dado por finalizado por el desarrollador; commit y push a su cargo): `main.gd`, `situation_definition.gd`, `situation_catalog.gd`, `tests/test_main_pass_resolution.gd` + `.uid` (nuevos), `tests/test_situation_definition.gd`, `tests/test_situation_catalog.gd` y documentación (`docs/DEVLOG.md`, `docs/PROJECT_STATE.md`, `docs/ROADMAP.md`).

## Escenas y sistemas presentes

| Área | Archivos | Estado verificado |
| --- | --- | --- |
| Inicio | `home/Home.tscn`, `home/home.gd` | Escena principal configurada. JUGAR abre el laboratorio. |
| Laboratorio | `level_select/LevelSelect.tscn`, `level_select/level_select.gd` | Una entrada por situación del catálogo, generada en código; sin bloqueos; marca ✓ de completada. |
| Situaciones | `situation_definition.gd`, `situation_catalog.gd` | Definición tipada por situación; catálogo en código; `main.gd` aplica la definición seleccionada al arrancar. Hoy: «Desmarque con presión». |
| Progreso | `game_progress.gd` | Persiste nivel actual, máximo desbloqueado y completado en `user://progress.cfg`; el laboratorio usa nivel actual (base 1, recortado al catálogo) y completadas. |
| Situación jugable | `main.tscn`, `main.gd` | Máquina de estados OFF_BALL → PASS → RESULT; rivales creados dinámicamente según `rival_count` (hoy 1). Desde T5 el pase se resuelve en tres outcomes excluyentes (`PRECISE`, `DEVIATED`, `INTERCEPTED`) con su mensaje en el HUD. |
| Cancha | `field/Field.tscn`, `field/field.gd` | Mitad ofensiva visual; geometría y regiones normalizadas expuestas. |
| Jugador | `player/Player.tscn`, `player/player.gd` | `CharacterBody2D` con WASD y aceleración; sin colisiones físicas. |
| Compañero | `teammate/Teammate.tscn`, `teammate/teammate.gd` | Escena propia (extraída de `main.tscn`); origen del pase. Desde T3 puede desplazarse gradualmente hacia su punto de apoyo durante OFF_BALL (`move_toward`), configurable por situación; hoy `holder_shift_distance = 0` lo mantiene estático. |
| Rival | `rival/Rival.tscn`, `rival/rival.gd` | Nodos instanciados dinámicamente por `main.gd`; cada uno tiene un rol: `PRESSURE` persigue al objetivo (jugador en OFF_BALL, pelota en PASS) y `COVERAGE` se mantiene a 150 px de la amenaza (punto medio entre jugador y pelota) pero del lado del arco rival (centro consultado a `Field`). Ambos se desplazan con `move_toward`. |
| Pelota | `ball/Ball.tscn`, `ball/ball.gd` | Pase con desaceleración constante; resolución por distancia en `main.gd`: contacto del jugador a `ball_contact_distance` (preciso), rival a `interception_distance` (interceptado; entre ambos umbrales solo acompaña) y salida de la cancha con gracia (desviado). |
| Evaluación | `situation_evaluator.gd` | Destino de pase con error aleatorio, asumiendo un rival; su `quality` sigue sin consumirse. `evaluate_pass_lane` estima la calidad de la línea contra una colección de rivales (distancia al segmento completo, determinista) y desde T5 modula la precisión efectiva del pase en `main.gd`. |
| Pruebas | `tests/` | Runner propio headless (`run_tests.gd`), aserciones mínimas y tests de evaluador, catálogo y rival. Comando y reporte en `docs/TESTING.md`. |

## Limitaciones verificadas

- La cantidad de rivales es configurable por situación (`rival_count`); desde T2 existen roles básicos (`PRESSURE` y `COVERAGE`, con asignación local en `main.gd`) y un `PASS_LANE` previsto pero sin implementar; todavía no hay configuración de roles por situación ni evaluación de pases contra todos los rivales. Un solo compañero por situación.
- El desplazamiento del compañero es configurable (`holder_shift_distance`, hoy 0 = estático; apoyo hacia el jugador durante OFF_BALL); el pase es automático al agotarse el temporizador.
- Contactos por distancia, sin colisiones físicas ni rebotes.
- El `quality` del destino del pase no se consume todavía; desde T5 la calidad de la línea sí modula la precisión. No hay evaluación separada de decisión, ejecución y resultado.
- Sin marcador, tiempo de partido, remate, audio ni animaciones.

## Comprobaciones y validaciones

Confirmado por el desarrollador:

- Suite automatizada después de T1: **28 comprobaciones, 0 fallas** (antes de T1: 26); la tarea de VS Code funciona.
- Validación manual de T1: la Situación 1 con 1 rival se comporta como antes; probada además con 2 y 6 rivales (con 6 la situación resulta muy difícil). La configuración quedó en 1 rival.
- Playtest manual de la Situación 1 tras la extracción del compañero.
- T5: el desarrollador ejecutó la suite tras el lote y confirmó que todo funcionó; además validó T5 manualmente y lo dio por finalizado. El commit y push quedan a su cargo.

Pendiente de confirmación:

- T2 y T3 (commiteados): validación de comportamiento sin reportar todavía. Para T2, prueba manual con `rival_count = 2` temporal; para T3, elevar temporalmente `holder_shift_distance` para ver el apoyo del poseedor (con 0 el comportamiento debe ser el actual).
- Procedencia de la prueba manual descrita en la entrada «Corrección de advertencias en Ball» del DEVLOG (incluida en el commit `96a4826`, junto con el cambio en `ball/ball.gd`).

Conocido y no bloqueante (decisión del desarrollador): un warning de colisión de `Player` durante la ejecución local.

El binario de Godot en la máquina del asistente no es ejecutable: toda ejecución de pruebas y validación corre por cuenta del desarrollador.

## Próximo objetivo (tras cerrar T5)

Sesión de diseño centrada en la experiencia jugable y el feedback visual, no otro lote de infraestructura técnica. Puntos de partida: legibilidad del desmarque bajo presión, señales de la calidad del pase antes y durante el envío, reacción del jugador a los tres resultados y ritmo de los reinicios. Las decisiones vigentes de T5, sus criterios de aceptación y los pendientes quedaron registrados en la entrada de T5 del DEVLOG para retomar sin reconstruir el historial.
