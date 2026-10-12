# Pruebas automatizadas

Runner propio, sin frameworks ni dependencias. Cubre lógica determinista
(evaluar, catálogo); todo lo visual o de sensación de juego se valida a mano.

## Requisitos

- Godot 4.7.2 (la misma versión del proyecto).
- PowerShell (incluido en Windows).

## Comando

```powershell
.\tests\run_tests.ps1 -GodotPath "C:\ruta\real\Godot_v4.7.2-stable_win64.exe"
```

O definiendo la ruta una vez por sesión:

```powershell
$env:GODOT = "C:\ruta\real\Godot_v4.7.2-stable_win64.exe"
.\tests\run_tests.ps1
```

Sin parámetro ni variable `GODOT`, el script intenta usar `godot` desde el PATH.

## Códigos de salida

| Código | Significado |
| --- | --- |
| 0 | Todas las comprobaciones pasaron. |
| 1 | Hubo comprobaciones fallidas, un script no pudo cargarse o falta `run()`. |
| 2 | No se encontró el ejecutable de Godot. |
| 3 | Timeout genérico: la suite no terminó en el plazo (ver Limitaciones). |

## Salida esperada en éxito

```text
D:/Projects/el-goat-game/tests/test_situation_evaluator.gd
    PASS  destino sin error coincide en X con el punto adelantado
    ...
--------------------------------------------------
TESTS: N comprobaciones, 0 fallas
RESULTADO: OK
```

Cada comprobación imprime `PASS` o `FAIL` con una descripción; el resumen final
imprime el total. Un fallo se reporta pegando la salida completa (donde cada
línea `FAIL` indica comprobación, valor esperado y obtenido).

## Formato de reporte por tarea

Al cerrar cada tarea se informa:

- **Ejecutadas:** comando exacto corrido y resultado del resumen.
- **Fallidas:** salida pegada, sin editar.
- **No ejecutadas:** si no se pudieron correr (indicar motivo).
- **Pendientes de validación manual:** checklist jugado a mano (movimiento,
  tacto del pase, presión rival, HUD, navegación, flujos de éxito/fallo).

## Agregar una prueba nueva

1. Crear `tests/test_<clase>.gd` que extienda `test_case.gd` e implemente `run()`.
2. Listo: el runner descubre automáticamente `res://tests/test_*.gd` en orden alfabético. No hay que registrar rutas en ningún archivo ni tocar la tarea de VS Code.

El descubrimiento excluye `test_case.gd` (clase base) y todo lo que no sea `test_*.gd` (por eso el runner no se detecta a sí mismo). Un archivo `test_*` sin `run()` hace fallar la suite con un mensaje claro, para que un helper mal nombrado no pase inadvertido. Los helpers que no son pruebas deben llamarse, por convención, sin el prefijo `test_`.

## Qué cubren los tests hoy

- `test_situation_evaluator.gd`: destino del pase sin error = punto adelantado
  exacto; destino siempre dentro de la zona segura con error extremo; calidad
  dentro de [0, 1] y sensible a la distancia del rival.
- `test_situation_catalog.gd`: identidad (id/título) de cada situación;
  `get_by_index` recorta índices fuera de rango; parámetros exactos de la
  Situación 1 (fija el equilibrio actual).

## Qué no cubren (validación manual)

Movimiento del jugador, tacto del pase, comportamiento del rival, HUD,
navegación Home/Laboratorio/Situación, flujos de éxito, fallo y reinicio.

## Limitaciones y reevaluación

- Los tests usan RNG sembrado: deterministas, pero solo cubren un camino del
  error aleatorio.
- El runner no puede capturar errores de ejecución de GDScript (no existe
  `try/catch` ni una API de errores). Un error en tiempo real dentro de un
  test se manifiesta como una colgada que la guardia cierra con código 3 tras
  el plazo (timeout genérico: no identifica la causa ni el archivo). El plazo
  por defecto es de 60 s y se puede ajustar con la variable de entorno
  `ELGOAT_TEST_TIMEOUT` (segundos) sin editar el runner.
- `GameProgress` no se testea todavía: escribe en `user://`; requeriría aislar
  la ruta de guardado (cambio de código, pediría aprobación aparte).
- Si el volumen de tests crece a decenas, reevaluar GUT. Mientras tanto el
  runner propio es suficiente y sin dependencias.

## Problemas frecuentes

- **Código 2:** la ruta de Godot es incorrecta (verificar con la versión que
  abre el editor).
- **PowerShell bloquea el script:** ejecutar
  `Unblock-File .\tests\run_tests.ps1` (solo si el archivo vino de otra
  máquina).
