extends RefCounted

## TestCase ofrece las aserciones mínimas del runner de pruebas propio
## (tests/run_tests.gd). Cada script de prueba extiende esta clase, ejecuta sus
## comprobaciones en run() y deja el resultado contado aquí para que el runner
## imprima el resumen y decida el código de salida. Es deliberadamente mínima:
## si el volumen de tests crece, conviene reevaluar un framework como GUT.

var total_checks := 0
var failed_checks := 0


func check(condition: bool, description: String) -> void:
	total_checks += 1

	if condition:
		print("    PASS  %s" % description)
	else:
		failed_checks += 1
		print("    FAIL  %s" % description)


func check_approx(actual: float, expected: float, description: String, epsilon := 0.0001) -> void:
	var matches := absf(actual - expected) <= epsilon
	check(matches, "%s (esperado %.4f, obtenido %.4f)" % [description, expected, actual])


func check_point_in_rect(point: Vector2, rect: Rect2, description: String, epsilon := 0.01) -> void:
	var inside := (
		point.x >= rect.position.x - epsilon
		and point.x <= rect.end.x + epsilon
		and point.y >= rect.position.y - epsilon
		and point.y <= rect.end.y + epsilon
	)
	check(inside, "%s (punto %s, rect %s)" % [description, point, rect])
