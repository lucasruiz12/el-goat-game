# Devlog

## 2026-10-12 — Punto de reanudación previo a compactación manual

- T5 (calidad del pase integrada en el resultado) fue dado por finalizado y aceptado por el desarrollador; el commit y el push quedan a su cargo. El worktree contiene T5 completo sin commitear: `main.gd`, `situation_definition.gd`, `situation_catalog.gd`, `tests/test_main_pass_resolution.gd` (nuevo, con `.uid`), `tests/test_situation_definition.gd`, `tests/test_situation_catalog.gd` y esta documentación.
- Confirmado por el desarrollador al cerrar T5: la suite tras el lote la ejecutó él y confirmó que todo funcionó, y validó T5 manualmente. Sigue sin reportar: validación manual de T2 y T3. Corregido durante T5: typo `DEBAITED`→`DEVIATED` en `main.gd` y en el test de outcomes (el error del `const` dict en el LSP era cascada de ese typo; `const` con claves de enum es sintaxis válida).
- Próximo objetivo acordado: **sesión de diseño centrada en la experiencia jugable y el feedback visual**, no otro lote de infraestructura. Cualquier lote posterior requiere autorización explícita del desarrollador.
- Para retomar: `docs/PROJECT_STATE.md` (estado y pendientes), esta entrada y la de T5 (decisiones y criterios de aceptación), `docs/TESTING.md` (comandos) y `AGENTS.md` (reglas: commits solo con aprobación, informar estado de pruebas, sin frameworks de QA).

## 2026-10-12 — T5: la calidad del pase influye en el resultado

- `start_pass()` evalúa la línea con `evaluate_pass_lane()` (compañero → jugador, contra todas las posiciones rivales del instante) y modula la precisión efectiva mediante `combine_precision_with_lane()`: con la línea despejada el pase sale igual que antes; con rivales sobre la línea la desviación crece de forma gradual y acotada (`maximum_pass_error` sigue siendo el techo). La desviación se aplica en el mismo `evaluate_pass_target` existente, sin duplicar sistemas.
- Resolución del pase con tres outcomes excluyentes (`PassOutcome`): `PRECISE` (el jugador recibe la pelota), `DEVIATED` (la pelota sale de la cancha y se agota la gracia) e `INTERCEPTED` (un rival queda dentro de `interception_distance`, nuevo parámetro por situación, 15 px). El contacto rival de 25 px ya no falla automáticamente: entre 15 y 25 px el rival acompaña la jugada sin resolverla — la proximidad por sí sola no intercepta.
- Feedback: el label del HUD muestra el mensaje del outcome («¡PASE PRECISO!», «PASE DESVIADO», «PASE INTERCEPTADO») en todos los resultados y se oculta al reiniciar. Un solo mensaje por outcome, sin resultados contradictorios. Decisión de diseño: el mensaje refleja la resolución real, no la intención — un pase desviado que el jugador alcanza igual termina en `PRECISE`.
- Pruebas: `tests/test_main_pass_resolution.gd` cubre funciones puras de `main.gd` (composición de precisión, umbral de intercepción, distinción de mensajes y éxito exclusivo) y definición/catálogo fijan `interception_distance` (suite en 76 comprobaciones). Corrida de la suite y validación manual de T5 confirmadas por el desarrollador al cerrar el lote.
- Criterios de aceptación de T5, registrados para el cierre: la calidad de T4 influye realmente en el pase; la posición de los rivales puede cambiar desviación y resultado; la intercepción exige el umbral definido sobre la trayectoria real; el feedback refleja lo ocurrido y el flujo de fases y reinicios sigue funcionando; la Situación 1 conserva 1 rival, compañero estático y `holder_shift_distance = 0.0`.
- Una vez validado y cerrado T5, el siguiente objetivo es una **sesión de diseño centrada en la experiencia jugable y el feedback visual**, no otro lote de infraestructura técnica.

## 2026-10-12 — T4: evaluación de líneas de pase contra múltiples rivales

- `situation_evaluator.gd` incorpora `evaluate_pass_lane(origin, target, rival_positions)`: mide la distancia de cada rival al **segmento completo** del pase (con `Geometry2D.get_closest_point_to_segment`, no solo a los extremos) y devuelve la calidad de la línea según el rival más cercano, con la misma escala de 220 px que ya usa el evaluador (`LANE_CLEARNESS_SCALE`). Determinista, sin RNG. Resultado: `lane_quality` en [0, 1] (1 con línea libre o sin rivales) y `closest_rival_distance` (INF sin rivales).
- `evaluate_pass_target` permanece intacto y el nuevo método todavía no se conecta a `main.gd`: este lote agrega y valida la lógica, sin cambiar el juego.
- Pruebas: seis casos nuevos (línea libre, rival junto al segmento, al origen y al destino, varios rivales con mínimo gobernante y colección vacía; suite en 61 comprobaciones). Todavía sin ejecutar: pendiente la corrida local del desarrollador. No requiere validación manual: no hay cambio de comportamiento en el juego.

## 2026-10-12 — T3: desplazamiento configurable del poseedor

- `SituationDefinition` incorpora la categoría «Teammate»: `holder_shift_distance` (por defecto 0.0, sin movimiento) y `holder_shift_speed` (60.0). «Desmarque con presión» los fija explícitamente en 0.0 y 60.0: la situación actual sigue con el compañero estático.
- `teammate.gd` expone `move_toward_target()` con el mismo patrón de `Rival`.
- `main.gd` actualiza el objetivo del poseedor solo durante OFF_BALL: sale a apoyar hacia el jugador sin alejarse más de `holder_shift_distance` de su posición inicial registrada al empezar la situación. El pase ya nacía de la posición actual del compañero (`ball.start_pass(teammate…)`), así que el apoyo se ejecuta desde donde esté. Con distancia 0 el objetivo es su propia posición: no se mueve y el comportamiento es idéntico al anterior.
- Pruebas: defaults de la definición, parámetros fijados en el catálogo y movimiento del compañero (suite en 49 comprobaciones). Todavía sin ejecutar: pendiente la corrida local y la prueba manual (levantar `holder_shift_distance` temporalmente para ver el apoyo).

## 2026-10-12 — T2: roles de rivales (presión y cobertura)

- `rival.gd` incorpora el enum `Role` (`PRESSURE`, `COVERAGE`) y `apply_coverage()`. Tras los ajustes pedidos por el desarrollador, `COVERAGE` defiende la zona entre la amenaza de la jugada —punto medio entre el jugador y la pelota— y el arco rival: se mantiene a `COVERAGE_DISTANCE` (150 px) de esa amenaza pero siempre del lado del arco (centro del arco consultado a `Field`), sin perseguir ni copiar el movimiento del jugador. `PRESSURE` conserva la persecución directa original. Queda anotado como rol futuro `PASS_LANE` (interceptar el pase compañero–jugador), sin implementar.
- `main.gd` asigna roles al instanciar (primer rival `PRESSURE`, resto `COVERAGE`) como asignación local mínima, todavía sin configuración por situación, y elige el objetivo según el rol al aplicar presión.
- La Situación 1 sigue con `rival_count = 1` y un rival `PRESSURE`: comportamiento sin cambios.
- Pruebas: `tests/test_rival.gd` cubre el rol por defecto, el movimiento de ambos roles, el cálculo puro del punto de cobertura (incluido el recorte en el arco y el caso de jugador y pelota desplazados a lados distintos) y que ambos roles terminan en objetivos distintos (suite en 41 comprobaciones; corrige el conteo de 37 informado en el ajuste anterior, que omitía una comprobación). Todavía sin ejecutar: pendiente la corrida local y la prueba manual del desarrollador (con `rival_count = 2` temporal).

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
