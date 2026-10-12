class_name Rival
extends Node2D

## Rival es una entidad autónoma de campo: conoce su rol y la forma de
## desplazarse, pero no decide a quién marcar; Main le pasa los objetivos y la
## velocidad, de modo que la coordinación de la situación sigue en Main.
##
## Roles vigentes (T2):
## - PRESSURE: persigue directamente al objetivo que le indica Main (el jugador
##   en OFF_BALL, la pelota en PASS). Es el comportamiento original, sin cambios.
## - COVERAGE: protege la zona entre la amenaza de la jugada y el arco rival.
##   La amenaza es el punto medio entre el jugador y la pelota: contempla tanto
##   al portador del balón como al posible receptor. La cobertura no persigue a
##   nadie; se mantiene a una distancia fija del punto de amenaza pero siempre
##   del lado del arco, dificultando el avance sin copiar el movimiento del
##   jugador. La orientación del campo no se asume aquí: Main consulta el centro
##   del arco a Field y pasa la posición.
## Pendiente (no implementar todavía): PASS_LANE, para interceptar el pase
## entre el compañero y el jugador.

enum Role {
	PRESSURE,
	COVERAGE,
}

## Distancia a la que COVERAGE se mantiene del punto de amenaza, medida hacia
## el arco. Es una constante de este rol hasta que la configuración por
## situación decida parametrizarla.
const COVERAGE_DISTANCE := 150.0

## Rol asignado por Main al instanciar. Por defecto PRESSURE para conservar el
## comportamiento de cualquier situación con un solo rival.
var role := Role.PRESSURE


func apply_pressure(target_position: Vector2, speed: float, delta: float) -> void:
	global_position = global_position.move_toward(target_position, speed * delta)


func apply_coverage(
	player_position: Vector2,
	ball_position: Vector2,
	rival_goal_position: Vector2,
	speed: float,
	delta: float,
) -> void:
	var coverage_point := calculate_coverage_point(
		player_position,
		ball_position,
		rival_goal_position,
		COVERAGE_DISTANCE,
	)
	global_position = global_position.move_toward(coverage_point, speed * delta)


## Cálculo puro del punto de cobertura: la amenaza es el punto medio entre
## jugador y pelota, y el objetivo queda a `distance_from_threat` de esa
## amenaza en la línea recta hacia el arco. Si la amenaza ya está más cerca del
## arco que esa distancia, el objetivo es el propio arco: la cobertura nunca se
## coloca más allá del arco. Se separa como función estática para poder probar
## la geometría sin escena ni nodos en movimiento.
static func calculate_coverage_point(
	player_position: Vector2,
	ball_position: Vector2,
	rival_goal_position: Vector2,
	distance_from_threat: float,
) -> Vector2:
	var threat_anchor := player_position.lerp(ball_position, 0.5)
	var toward_goal := rival_goal_position - threat_anchor
	var goal_distance := toward_goal.length()

	if goal_distance <= distance_from_threat:
		return rival_goal_position

	return threat_anchor + toward_goal.normalized() * distance_from_threat
