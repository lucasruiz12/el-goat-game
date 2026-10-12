# Estado técnico verificado

Auditoría: 2026-10-11. Este documento describe archivos inspeccionados; no sustituye una prueba manual de gameplay.

## Estado de Git al iniciar la auditoría

- `HEAD`: `50f42a1 feat: add level progression and unlocks`.
- Cambio preexistente no rastreado: `export_presets.cfg`.
- No se encontraron cambios rastreados antes de crear esta documentación.

## Escenas y sistemas presentes

| Área | Archivos | Estado verificado |
| --- | --- | --- |
| Inicio | `home/Home.tscn`, `home/home.gd` | Escena principal configurada. El botón **JUGAR** navega al selector. |
| Selector | `level_select/LevelSelect.tscn`, `level_select/level_select.gd` | Muestra cuatro botones; usa `GameProgress` para bloquear, desbloquear y marcar completados. |
| Progreso | `game_progress.gd` | Clase estática que persiste nivel actual, máximo desbloqueado y completado en `user://progress.cfg`; limita el desbloqueo a nivel 3. |
| Laboratorio de situación | `main.tscn`, `main.gd` | Compone cancha, jugador, compañero, rival, pelota y barra temporal. |
| Cancha | `field/Field.tscn`, `field/field.gd` | Mitad ofensiva visual con arco, áreas, línea de mitad, semicírculo central, punto central, medialuna y punto penal. Expone rectángulo de campo y regiones normalizadas. |
| Jugador | `player/Player.tscn`, `player/player.gd` | `CharacterBody2D` con WASD, aceleración, desaceleración y `move_and_slide()`. |
| Pelota | `ball/Ball.tscn`, `ball/ball.gd` | Entidad separada que inicia un pase, avanza con velocidad y desacelera hasta detenerse. |
| Rival | `rival/Rival.tscn`, `rival/rival.gd` | Nodo visual que aplica presión acercándose al objetivo indicado. |
| Evaluación | `situation_evaluator.gd` | Calcula una zona probable de pase usando separación, espacio respecto del rival, profundidad, dirección del jugador y precisión del pase. |

## Loop de situación leído en código

1. `Main` coloca jugador, compañero y rival aleatoriamente en regiones normalizadas de la cancha.
2. Durante `OFF_BALL`, el temporizador baja y el rival se mueve hacia el jugador.
3. Al agotarse, `SituationEvaluator` produce un destino de pase adelantado e imperfecto; `Ball` inicia el desplazamiento desde el compañero.
4. Durante `PASS`, el rival presiona la posición de la pelota. Contacto jugador-pelota produce éxito; contacto rival-pelota produce fallo. Si la pelota sale de la cancha y vence la gracia, también falla.
5. Éxito completa el nivel actual y navega al selector; fallo espera el reinicio y crea otra situación.

## Limitaciones verificadas

- Los cuatro botones del selector no cargan escenas o configuraciones diferentes: niveles 1, 2 y 3 llevan al mismo `main.tscn`; los parámetros de dificultad no se derivan del nivel actual.
- No hay colisiones físicas: los contactos se resuelven por distancia.
- No hay IA defensiva, rebotes, pase con efecto, animaciones, audio, estadísticas ni simulación de partido conectado.
- El destino calculado del pase se conserva en `Ball.destination`, pero la pelota continúa por inercia y no se detiene necesariamente allí.
- `README.md` solo contiene el título del proyecto.

## Comprobaciones realizadas en esta auditoría

- Se inspeccionaron los archivos listados y la configuración del proyecto Godot 4.7.
- Godot 4.7.2 cargó en modo headless la escena principal (`Home`), el selector y `main.tscn`, durante 10 frames cada una, sin errores de parseo/carga reportados.
- `git diff --check` finalizó sin salida.

No se verificaron manualmente controles WASD, navegación de botones, persistencia de `user://progress.cfg`, resultado de contactos, presentación visual ni exportación. La ejecución headless emitió avisos del entorno al escribir `user://logs` y al consultar certificados del sistema.
