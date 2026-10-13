extends "res://tests/test_case.gd"

## Pruebas de Teammate: protegen el movimiento gradual del poseedor con el
## mismo patrón determinista que Rival (posiciones y distancias, sobre un nodo
## suelto y sin escena principal).

const TeammateScript = preload("res://teammate/teammate.gd")


func run() -> void:
	test_move_toward_target_advances_the_requested_distance()
	test_move_toward_target_does_not_deviate()


func test_move_toward_target_advances_the_requested_distance() -> void:
	var teammate: TeammateScript = TeammateScript.new()
	teammate.global_position = Vector2.ZERO

	teammate.move_toward_target(Vector2(100.0, 0.0), 40.0, 1.0)

	check_approx(teammate.global_position.x, 40.0, "el poseedor avanza la velocidad indicada hacia su apoyo")
	check_approx(teammate.global_position.y, 0.0, "el poseedor no se desvía del rumbo en Y")
	teammate.free()


func test_move_toward_target_does_not_deviate() -> void:
	var teammate: TeammateScript = TeammateScript.new()
	teammate.global_position = Vector2(0.0, 50.0)

	teammate.move_toward_target(Vector2(0.0, 0.0), 20.0, 1.0)

	check_approx(teammate.global_position.x, 0.0, "el poseedor mantiene la línea del apoyo en X")
	check_approx(teammate.global_position.y, 30.0, "el poseedor se acerca al apoyo en la distancia correcta en Y")
	teammate.free()
