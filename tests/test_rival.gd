extends "res://tests/test_case.gd"

## Pruebas de Rival: protegen el rol por defecto, la geometría pura del punto
## de cobertura (que considera jugador y pelota) y que cada rol termina en un
## objetivo distinto. Es lógica determinista (posiciones y distancias) sobre
## nodos sueltos, sin depender de la escena principal.

const RivalScript = preload("res://rival/rival.gd")

const PLAYER := Vector2(0.0, 100.0)
const BALL := Vector2(100.0, 100.0)
const RIVAL_GOAL := Vector2(0.0, -50.0)


func run() -> void:
	test_default_role_is_pressure()
	test_pressure_moves_straight_toward_target()
	test_coverage_point_sits_toward_the_goal()
	test_coverage_point_clamps_at_the_goal()
	test_coverage_accounts_for_the_ball()
	test_coverage_moves_toward_its_point()
	test_roles_pursue_different_objectives()


func test_default_role_is_pressure() -> void:
	var rival: RivalScript = RivalScript.new()

	check(rival.role == RivalScript.Role.PRESSURE, "el rol por defecto es PRESSURE")
	rival.free()


func test_pressure_moves_straight_toward_target() -> void:
	var rival: RivalScript = RivalScript.new()
	rival.global_position = Vector2.ZERO

	rival.apply_pressure(PLAYER, 40.0, 1.0)

	check_approx(rival.global_position.x, 0.0, "PRESSURE no se desvía del rumbo en X")
	check_approx(rival.global_position.y, 40.0, "PRESSURE avanza la velocidad indicada hacia el jugador")
	rival.free()


func test_coverage_point_sits_toward_the_goal() -> void:
	# Con la pelota sobre el jugador, la amenaza es el propio jugador.
	var point: Vector2 = RivalScript.calculate_coverage_point(
		PLAYER,
		PLAYER,
		RIVAL_GOAL,
		30.0,
	)

	check_approx(point.x, 0.0, "el punto de cobertura queda en la línea amenaza-arco en X")
	check_approx(point.y, 70.0, "el punto de cobertura queda 30 px de la amenaza hacia el arco en Y")


func test_coverage_point_clamps_at_the_goal() -> void:
	var clamped: Vector2 = RivalScript.calculate_coverage_point(
		Vector2(0.0, -40.0),
		Vector2(0.0, -40.0),
		RIVAL_GOAL,
		30.0,
	)
	var same_spot: Vector2 = RivalScript.calculate_coverage_point(
		RIVAL_GOAL,
		RIVAL_GOAL,
		RIVAL_GOAL,
		30.0,
	)

	check(clamped == RIVAL_GOAL, "con la amenaza más cerca del arco que la distancia, el objetivo es el arco")
	check(same_spot == RIVAL_GOAL, "con la amenaza sobre el arco no hay división por cero")


func test_coverage_accounts_for_the_ball() -> void:
	# El jugador retrocede alejándose de la pelota: la cobertura no debe copiar
	# su movimiento, sino responder a la amenaza (punto medio jugador-pelota)
	# manteniéndose del lado del arco.
	var player_away := Vector2(-100.0, 200.0)
	var point: Vector2 = RivalScript.calculate_coverage_point(
		player_away,
		BALL,
		RIVAL_GOAL,
		30.0,
	)

	check_approx(point.x, 0.0, "la amenaza considera la pelota: el punto queda centrado en X entre jugador y pelota")
	check_approx(point.y, 120.0, "la amenaza es el punto medio jugador-pelota y el punto sigue a 30 px hacia el arco")
	check(point.y < player_away.y, "el punto de cobertura permanece del lado del arco respecto del jugador")


func test_coverage_moves_toward_its_point() -> void:
	var rival: RivalScript = RivalScript.new()
	rival.global_position = Vector2.ZERO
	var point: Vector2 = RivalScript.calculate_coverage_point(
		PLAYER,
		PLAYER,
		RIVAL_GOAL,
		RivalScript.COVERAGE_DISTANCE,
	)

	rival.apply_coverage(PLAYER, PLAYER, RIVAL_GOAL, 10.0, 1.0)

	check(
		rival.global_position.distance_to(point) < Vector2.ZERO.distance_to(point),
		"COVERAGE se acerca a su punto de cobertura"
	)
	rival.free()


func test_roles_pursue_different_objectives() -> void:
	var pressure_rival: RivalScript = RivalScript.new()
	var coverage_rival: RivalScript = RivalScript.new()
	pressure_rival.global_position = Vector2.ZERO
	coverage_rival.global_position = Vector2.ZERO

	pressure_rival.apply_pressure(PLAYER, 40.0, 1.0)
	coverage_rival.apply_coverage(PLAYER, PLAYER, RIVAL_GOAL, 40.0, 1.0)

	check(
		pressure_rival.global_position.y > coverage_rival.global_position.y,
		"PRESSURE queda del lado del jugador y COVERAGE del lado del arco"
	)
	check(
		coverage_rival.global_position.y < PLAYER.y,
		"COVERAGE no termina sobre el jugador: se interpone hacia el arco"
	)
	pressure_rival.free()
	coverage_rival.free()
