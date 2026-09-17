class_name SituationEvaluator
extends RefCounted

## SituationEvaluator transforma el desmarque actual en una zona probable de pase.
## Combina separacion, profundidad hacia el arco y espacio respecto del rival en una
## regla pequena y explicable. El resultado es un Dictionary temporal para no fijar
## todavia una estructura de datos que una futura evaluacion tactica podria superar.

func evaluate_pass_target(player_position: Vector2, player_velocity: Vector2, teammate_position: Vector2, rival_position: Vector2, field_rect: Rect2, pass_precision: float, lead_distance: float, maximum_pass_error: float, random_number_generator: RandomNumberGenerator) -> Dictionary:
	var separation := player_position.distance_to(teammate_position)
	var rival_distance := player_position.distance_to(rival_position)
	var forward_gain := teammate_position.y - player_position.y
	var movement_direction := player_velocity.normalized()
	if movement_direction == Vector2.ZERO:
		movement_direction = Vector2.UP

	var lead_target := player_position + movement_direction * lead_distance
	var error_magnitude := maximum_pass_error * (1.0 - clampf(pass_precision, 0.0, 1.0))
	var error_angle := random_number_generator.randf_range(0.0, TAU)
	var target := lead_target + Vector2(cos(error_angle), sin(error_angle)) * error_magnitude
	var safe_rect := field_rect.grow(-24.0)
	target = clamp_to_rect(target, safe_rect)
	if target.distance_to(player_position) < lead_distance * 0.5:
		target = clamp_to_rect(player_position + movement_direction * lead_distance, safe_rect)

	var separation_score := clampf((separation - 80.0) / 220.0, 0.0, 1.0)
	var space_score := clampf(rival_distance / 220.0, 0.0, 1.0)
	var depth_score := clampf((forward_gain + 40.0) / 220.0, 0.0, 1.0)
	return {
		"pass_target": target,
		"quality": separation_score * 0.4 + space_score * 0.35 + depth_score * 0.25,
	}


func clamp_to_rect(point: Vector2, rect: Rect2) -> Vector2:
	return Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y),
	)
