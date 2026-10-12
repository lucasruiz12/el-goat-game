extends SceneTree

## Runner mínimo de pruebas para Godot headless. Se ejecuta con:
##   godot --headless --path <proyecto> -s res://tests/run_tests.gd
## (envuelto por tests/run_tests.ps1; ver docs/TESTING.md).
##
## Descubre automáticamente los archivos res://tests/test_*.gd (excepto la
## clase base test_case.gd), los ejecuta en orden alfabético y usa los
## contadores de test_case.gd para decidir el código de salida:
##   0 = todo pasó
##   1 = hubo fallas, un script no cargó o falta run()
##   3 = timeout genérico (la suite no terminó en el plazo)
## No depende de ningún framework: si el volumen de tests crece, reevaluar
## GUT (docs/TESTING.md).

const TESTS_DIRECTORY := "res://tests"
const TEST_FILE_PREFIX := "test_"
const TEST_FILE_EXTENSION := ".gd"

## Archivos que cumplen el patrón test_*.gd pero no son pruebas ejecutables.
const HELPER_SCRIPT_NAMES := ["test_case.gd"]

## Plazo holgado para una suite de segundos que puede crecer. Se puede
## sobreescribir sin editar el archivo con la variable de entorno
## ELGOAT_TEST_TIMEOUT (segundos).
const SUITE_TIMEOUT_SECONDS := 60.0
const TIMEOUT_EXIT_CODE := 3

var suite_finished := false


func _initialize() -> void:
	var paths := discover_test_paths()
	print("Suite: %d archivos de prueba" % paths.size())

	var total_checks := 0
	var total_failures := 0

	for path in paths:
		var script = load(path)
		if script == null:
			total_failures += 1
			print("  FAIL  No se pudo cargar %s (error de parseo o ruta)" % path)
			continue

		print(path)
		var test = script.new()
		if not test.has_method("run"):
			total_failures += 1
			print("  FAIL  %s no es una prueba ejecutable: falta run()" % path)
			continue

		test.run()
		total_checks += test.total_checks
		total_failures += test.failed_checks

	print("--------------------------------------------------")
	print("TESTS: %d comprobaciones, %d fallas" % [total_checks, total_failures])

	suite_finished = true

	if total_failures > 0:
		print("RESULTADO: FALLOS")
		quit(1)
		return

	print("RESULTADO: OK")
	quit(0)


func discover_test_paths() -> Array:
	var directory := DirAccess.open(TESTS_DIRECTORY)
	if directory == null:
		print("  FAIL  No se pudo abrir %s" % TESTS_DIRECTORY)
		return []

	var paths: Array = []
	for file_name in directory.get_files():
		if is_test_file(file_name):
			paths.append("%s/%s" % [TESTS_DIRECTORY, file_name])

	# Orden alfabético: el orden de get_files() depende del sistema operativo.
	paths.sort()
	return paths


func is_test_file(file_name: String) -> bool:
	# Esto excluye el runner y los .gd.uid que genera el editor (no terminan
	# en .gd), además de todo lo que no siga la convención test_<algo>.gd.
	if not file_name.begins_with(TEST_FILE_PREFIX):
		return false
	if not file_name.ends_with(TEST_FILE_EXTENSION):
		return false

	return not file_name in HELPER_SCRIPT_NAMES


func _process(_delta: float) -> bool:
	# Guardia anti-colgada. Es un timeout genérico: el runner no puede
	# detectar errores de ejecución de GDScript (no hay try/catch ni una API
	# de errores), así que un error en tiempo real dentro de un test se
	# manifiesta como una colgada que esta guardia cierra con código 3, no
	# como una falla con nombre propio.
	if not suite_finished and Time.get_ticks_msec() / 1000.0 > get_suite_timeout_seconds():
		print("ERROR: la suite no terminó en %.0f segundos (timeout genérico)." % get_suite_timeout_seconds())
		print("Posible bloqueo o error de ejecución dentro de un test; revisá la última salida de la consola.")
		quit(TIMEOUT_EXIT_CODE)
		return false

	return false


func get_suite_timeout_seconds() -> float:
	var override := OS.get_environment("ELGOAT_TEST_TIMEOUT")
	if override.is_empty():
		return SUITE_TIMEOUT_SECONDS

	var parsed := override.to_float()
	if parsed <= 0.0:
		return SUITE_TIMEOUT_SECONDS

	return parsed
