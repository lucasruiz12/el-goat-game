extends Node2D

const FieldScript = preload("res://field/field.gd")
const BallScript = preload("res://ball/ball.gd")
const RivalScript = preload("res://rival/rival.gd")
const SituationEvaluatorScript = preload("res://situation_evaluator.gd")

## Main compone la situacion jugable y avanza sus estados: desmarque, pase y
## resultado. Las entidades se ocupan de su propio movimiento y el evaluador genera
## el pase, de modo que este nodo solo coordina la secuencia completa.

enum SituationState {
	OFF_BALL,
	PASS,
	RESULT,
}

@export_category("Off-ball timing")
@export var off_ball_duration := 2.0
@export var restart_interval := 1.0

@export_category("Pass")
@export var ball_speed := 350.0
@export_range(0.0, 1.0, 0.05) var teammate_pass_precision := 0.72
@export var pass_lead_distance := 72.0
@export var maximum_pass_error := 80.0
@export var ball_contact_distance := 25.0
@export var ball_outside_grace_duration := 0.5

@export_category("Rival")
@export var rival_speed := 115.0
@export var minimum_initial_rival_distance := 150.0

@export_category("Starting regions")
@export var player_start_region := Rect2(0.35, 0.75, 0.30, 0.16)
@export var teammate_start_region := Rect2(0.33, 0.55, 0.34, 0.17)
@export var rival_start_region := Rect2(0.30, 0.18, 0.40, 0.28)

const PLAYER_COLOR := Color(0.2, 0.75, 1.0)
const SUCCESS_COLOR := Color(0.3, 1.0, 0.5)
const FAILURE_COLOR := Color(1.0, 0.35, 0.3)

@onready var field: FieldScript = $Field
@onready var player: CharacterBody2D = $Player
@onready var player_visual: Polygon2D = $Player/Visual
@onready var teammate: Polygon2D = $Teammate
@onready var rival: RivalScript = $Rival
@onready var ball: BallScript = $Ball
@onready var off_ball_timer: ProgressBar = $Hud/OffBallTimer
@onready var level_complete_label: Label = $Hud/LevelCompleteLabel

var evaluator: SituationEvaluatorScript = SituationEvaluatorScript.new()
var random_number_generator := RandomNumberGenerator.new()
var remaining_time := 0.0
var ball_outside_time_remaining := 0.0
var situation_state := SituationState.RESULT


func _ready() -> void:
	random_number_generator.randomize()
	ball.pass_finished.connect(_on_ball_pass_finished)
	off_ball_timer.max_value = off_ball_duration
	start_situation()


func _process(delta: float) -> void:
	match situation_state:
		SituationState.OFF_BALL:
			update_off_ball_phase(delta)
		SituationState.PASS:
			update_pass_phase(delta)


func start_situation() -> void:
	place_initial_positions()
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

	remaining_time = maxf(remaining_time - delta, 0.0)
	off_ball_timer.value = remaining_time

	if is_zero_approx(remaining_time):
		start_pass()


func start_pass() -> void:
	var evaluation := evaluator.evaluate_pass_target(
		player.global_position,
		player.velocity,
		teammate.global_position,
		rival.global_position,
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

	if ball.global_position.distance_to(rival.global_position) <= ball_contact_distance:
		finish_situation(false)
		return


func update_ball_outside_timer(delta: float) -> void:
	if is_zero_approx(ball_outside_time_remaining):
		ball_outside_time_remaining = ball_outside_grace_duration
		return

	ball_outside_time_remaining = maxf(ball_outside_time_remaining - delta, 0.0)

	if is_zero_approx(ball_outside_time_remaining):
		finish_situation(false)


func apply_rival_pressure(target_position: Vector2, delta: float) -> void:
	rival.apply_pressure(target_position, rival_speed, delta)


func place_initial_positions() -> void:
	player.global_position = random_position_in_region(player_start_region)
	teammate.global_position = random_position_in_region(teammate_start_region)
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