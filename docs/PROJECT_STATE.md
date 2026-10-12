# Estado técnico verificado

Auditoría: 2026-10-12. Describe lo inspeccionado en código; no sustituye una prueba manual de gameplay. El detalle de las pruebas automatizadas vive en `docs/TESTING.md`; el historial de cambios, en `docs/DEVLOG.md`.

## Estado de Git

- `HEAD`: `4511875 refactor: extract teammate into reusable scene`.
- Sin cambios commiteados al cerrar esta auditoría, más el trabajo sin commitear de esta tanda: infraestructura de pruebas (`tests/`), `docs/TESTING.md` y actualización de documentos.

## Escenas y sistemas presentes

| Área | Archivos | Estado verificado |
| --- | --- | --- |
| Inicio | `home/Home.tscn`, `home/home.gd` | Escena principal configurada. JUGAR abre el laboratorio. |
| Laboratorio | `level_select/LevelSelect.tscn`, `level_select/level_select.gd` | Una entrada por situación del catálogo, generada en código; sin bloqueos; marca ✓ de completada. |
| Situaciones | `situation_definition.gd`, `situation_catalog.gd` | Definición tipada por situación; catálogo en código; `main.gd` aplica la definición seleccionada al arrancar. Hoy: «Desmarque con presión». |
| Progreso | `game_progress.gd` | Persiste nivel actual, máximo desbloqueado y completado en `user://progress.cfg`; el laboratorio usa nivel actual (base 1, recortado al catálogo) y completadas. |
| Situación jugable | `main.tscn`, `main.gd` | Máquina de estados OFF_BALL → PASS → RESULT; contacto por distancia; rival único. |
| Cancha | `field/Field.tscn`, `field/field.gd` | Mitad ofensiva visual; geometría y regiones normalizadas expuestas. |
| Jugador | `player/Player.tscn`, `player/player.gd` | `CharacterBody2D` con WASD y aceleración; sin colisiones físicas. |
| Compañero | `teammate/Teammate.tscn`, `teammate/teammate.gd` | Escena propia (extraída de `main.tscn`); entidad posicional sin movimiento propio; origen del pase. |
| Rival | `rival/Rival.tscn`, `rival/rival.gd` | Un nodo que se desplaza con `move_toward`; el objetivo lo elige `main.gd` (jugador en OFF_BALL, pelota en PASS). |
| Pelota | `ball/Ball.tscn`, `ball/ball.gd` | Pase con desaceleración constante; contactos resueltos por distancia en `main.gd`. |
| Evaluación | `situation_evaluator.gd` | Destino de pase con error aleatorio, asumiendo un rival; `quality` calculado sin consumir. |
| Pruebas | `tests/` | Runner propio headless (`run_tests.gd`), aserciones mínimas y tests de evaluador y catálogo. Comando y reporte en `docs/TESTING.md`. |

## Limitaciones verificadas

- Un solo rival y un solo compañero por situación; sin roles de presión/cobertura.
- El compañero no se desplaza; el pase es automático al agotarse el temporizador.
- Contactos por distancia, sin colisiones físicas ni rebotes.
- El `quality` del evaluador no se consume; no hay evaluación separada de decisión, ejecución y resultado.
- Sin marcador, tiempo de partido, remate, audio ni animaciones.

## Comprobaciones de esta auditoría

- Inspección de código de los sistemas tabulados y de `main.tscn`/`LevelSelect.tscn`.
- Playtest manual de la Situación 1 tras la extracción del compañero, reportado por el desarrollador.
- La infraestructura de pruebas todavía no se ejecutó: pendiente la primera corrida local con Godot 4.7.2 (el binario presente en la máquina del asistente no es ejecutable).
