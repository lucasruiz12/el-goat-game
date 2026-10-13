extends Node2D

const FieldScript = preload("res://field/field.gd")
const BallScript = preload("res://ball/ball.gd")
const RivalScript = preload("res://rival/rival.gd")
const RivalScene = preload("res://rival/Rival.tscn")
const TeammateScript = preload("res://teammate/teammate.gd")
const SituationEvaluatorScript = preload("res://situation_evaluator.gd")

## Main compone la situacion jugable y avanza sus estados: desmarque, pase y
## resultado. Las entidades se ocupan de su propio movimiento y el evaluador genera
## el pase, de modo que este nodo solo coordina la secuencia completa.

enum SituationState {
	OFF_BALL,
	PASS,
	RESULT,
}

## Parámetros de la situación actual. Main no tiene valores propios: los toma
## de la SituationDefinition seleccionada (ver apply_selected_situation) para
## que la configuración del laboratorio viva en un solo lugar.
var off_ball_duration: float
var restart_interval: float
var ball_speed: float
var teammate_pass_precision: float
var pass_lead_distance: float
var maximum_pass_error: float
var ball_contact_distance: float
var ball_outside_grace_duration: float
var holder_shift_distance: float
var holder_shift_speed: float
var rival_speed: float
var rival_count: int
var minimum_initial_rival_distance: float
var player_start_region: Rect2
var teammate_start_region: Rect2
var rival_start_region: Rect2

const PLAYER_COLOR := Color(0.2, 0.75, 1.0)
const SUCCESS_COLOR := Color(0.3, 1.0, 0.5)
const FAILURE_COLOR := Color(1.0, 0.35, 0.3)

@onready var field: FieldScript = $Field
@onready var player: CharacterBody2D = $Player
@onready var player_visual: Polygon2D = $Player/Visual
@onready var teammate: TeammateScript = $Teammate
@onready var ball: BallScript = $Ball
@onready var off_ball_timer: ProgressBar = $Hud/OffBallTimer
@onready var level_complete_label: Label = $Hud/LevelCompleteLabel

var rivals: Array[RivalScript] = []
var evaluator: SituationEvaluatorScript = SituationEvaluatorScript.new()
var random_number_generator := RandomNumberGenerator.new()
var remaining_time := 0.0
var ball_outside_time_remaining := 0.0
var holder_start_position := Vector2.ZERO
var situation_state := SituationState.RESULT


func _ready() -> void:
	random_number_generator.randomize()
	ball.pass_finished.connect(_on_ball_pass_finished)
	apply_selected_situation()
	spawn_rivals()
	off_ball_timer.max_value = off_ball_duration
	start_situation()


func apply_selected_situation() -> void:
	# GameProgress guarda el nivel en base 1 por compatibilidad con el progreso
	# previo; el catálogo se indexa desde cero y get_by_index recorta valores
	# fuera de rango para que un save antiguo no rompa el arranque.
	var situation := SituationCatalog.get_by_index(GameProgress.get_current_level() - 1)

	off_ball_duration = situation.off_ball_duration
	restart_interval = situation.restart_interval
	ball_speed = situation.ball_speed
	teammate_pass_precision = situation.teammate_pass_precision
	pass_lead_distance = situation.pass_lead_distance
	maximum_pass_error = situation.maximum_pass_error
	ball_contact_distance = situation.ball_contact_distance
	ball_outside_grace_duration = situation.ball_outside_grace_duration
	holder_shift_distance = situation.holder_shift_distance
	holder_shift_speed = situation.holder_shift_speed
	rival_speed = situation.rival_speed
	rival_count = situation.rival_count
	minimum_initial_rival_distance = situation.minimum_initial_rival_distance
	player_start_region = situation.player_start_region
	teammate_start_region = situation.teammate_start_region
	rival_start_region = situation.rival_start_region


func spawn_rivals() -> void:
	# Los rivales se crean una sola vez por escena; cada reinicio de situación
	# solo los reubica. El evaluador todavía asume un solo rival, así que
	# garantizamos al menos una unidad aunque una situación pida 0.
	var amount := maxi(rival_count, 1)

	for _index in amount:
		var rival: RivalScript = RivalScene.instantiate()
		# Asignación local de roles para probar T2: presiona el primero y cubren
		# el resto. Todavía no proviene de la SituationDefinition.
		rival.role = RivalScript.Role.PRESSURE if _index == 0 else RivalScript.Role.COVERAGE
		add_child(rival)
		rivals.append(rival)


func _process(delta: float) -> void:
	match situation_state:
		SituationState.OFF_BALL:
			update_off_ball_phase(delta)
		SituationState.PASS:
			update_pass_phase(delta)


func start_situation() -> void:
	place_initial_positions()
	holder_start_position = teammate.global_position
	ball.reset_at(teammate.global_position)
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	player_visual.color = PLAYER_COLOR
	remaining_time = off_ball_duration
	off_ball_timer.max_value = off_ball_duration
	off_ball_timer.value = remaining_time
	off_ball_timer.visible = true
	ball_outside_time_remaining = 0.0
	situation_state = SituationState.OFF_BALL


func update_off_ball_phase(delta: float) -> void:
	apply_rival_pressure(player.global_position, delta)
	update_holder_position(delta)

	remaining_time = maxf(remaining_time - delta, 0.0)
	off_ball_timer.value = remaining_time

	if is_zero_approx(remaining_time):
		start_pass()


func update_holder_position(delta: float) -> void:
	# El poseedor sale a apoyar hacia el jugador, pero sin alejarse más de
	# holder_shift_distance de su posición inicial. Con distancia 0 el objetivo
	# es su propia posición: no se mueve y el comportamiento es el anterior.
	var shift_target := holder_start_position + (
		player.global_position - holder_start_position
	).limit_length(holder_shift_distance)

	teammate.move_toward_target(shift_target, holder_shift_speed, delta)


func start_pass() -> void:
	# El evaluador todavía modela un solo rival (su firma recibe una posición):
	# se usa al primero de la colección.
	var evaluation := evaluator.evaluate_pass_target(
		player.global_position,
		player.velocity,
		teammate.global_position,
		rivals[0].global_position,
		field.get_field_rect(),
		teammate_pass_precision,
		pass_lead_distance,
		maximum_pass_error,
		random_number_generator,
	)

	ball.start_pass(teammate.global_position, evaluation.pass_target, ball_speed)
	off_ball_timer.visible = false
	ball_outside_time_remaining = 0.0
	situation_state = SituationState.PASS


func update_pass_phase(delta: float) -> void:
	var ball_is_inside_field := field.get_field_rect().has_point(ball.global_position)

	if not ball_is_inside_field:
		update_ball_outside_timer(delta)
		return

	apply_rival_pressure(ball.global_position, delta)

	if ball.global_position.distance_to(player.global_position) <= ball_contact_distance:
		finish_situation(true)
		return

	if has_rival_ball_contact():
		finish_situation(false)
		return


func has_rival_ball_contact() -> bool:
	for rival in rivals:
		if ball.global_position.distance_to(rival.global_position) <= ball_contact_distance:
			return true

	return false


func update_ball_outside_timer(delta: float) -> void:
	if is_zero_approx(ball_outside_time_remaining):
		ball_outside_time_remaining = ball_outside_grace_duration
		return

	ball_outside_time_remaining = maxf(ball_outside_time_remaining - delta, 0.0)

	if is_zero_approx(ball_outside_time_remaining):
		finish_situation(false)


func apply_rival_pressure(target_position: Vector2, delta: float) -> void:
	for rival in rivals:
		if rival.role == RivalScript.Role.COVERAGE:
			# COVERAGE defiende la zona entre la amenaza de la jugada (punto
			# medio entre jugador y pelota) y el arco rival. El centro del arco
			# se consulta a Field (arriba, y = 0 del campo); así el objetivo no
			# copia el movimiento del jugador y siempre queda del lado del arco.
			rival.apply_coverage(
				player.global_position,
				ball.global_position,
				field.get_rival_goal_center(),
				rival_speed,
				delta,
			)
		else:
			rival.apply_pressure(target_position, rival_speed, delta)


func place_initial_positions() -> void:
	player.global_position = random_position_in_region(player_start_region)
	teammate.global_position = random_position_in_region(teammate_start_region)

	for rival in rivals:
		rival.global_position = random_position_in_region(rival_start_region)

		var attempts := 0
		while rival.global_position.distance_to(player.global_position) < minimum_initial_rival_distance and attempts < 8:
			rival.global_position = random_position_in_region(rival_start_region)
			attempts += 1


func random_position_in_region(region: Rect2) -> Vector2:
	var world_region := field.get_relative_rect(region)

	return Vector2(
		random_number_generator.randf_range(world_region.position.x, world_region.end.x),
		random_number_generator.randf_range(world_region.position.y, world_region.end.y),
	)


func _on_ball_pass_finished() -> void:
	# La pelota puede quedar quieta dentro de la cancha. Eso no termina
	# la situacion: jugador y rival siguen teniendo la oportunidad de tocarla.
	pass


func finish_situation(succeeded: bool) -> void:
	if situation_state == SituationState.RESULT:
		return

	situation_state = SituationState.RESULT
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO

	if succeeded:
		ball.stop_at(player.global_position)
		player_visual.color = SUCCESS_COLOR
		level_complete_label.visible = true

		GameProgress.complete_current_level()

		await get_tree().create_timer(restart_interval).timeout
		get_tree().change_scene_to_file("res://level_select/LevelSelect.tscn")
		return

	player_visual.color = FAILURE_COLOR

	await get_tree().create_timer(restart_interval).timeout
	start_situation()
