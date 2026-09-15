extends Node2D

## Main coordina una situacion de desmarque acotada. El tiempo restante se actualiza
## solo mientras la situacion esta activa y la ProgressBar muestra la misma fraccion,
## sin crear un sistema de UI general. La evaluacion provisional vive en una funcion
## aislada para poder reemplazarla luego por criterios tacticos mas completos.

@export_category("Off-ball tuning")
@export var off_ball_duration := 2.0
@export var restart_interval := 0.75
@export var teammate_start_position := Vector2(560.0, 450.0)
@export var player_start_position := Vector2(640.0, 540.0)
@export var provisional_forward_gain := 80.0

const PLAYER_COLOR := Color(0.2, 0.75, 1.0)
const SUCCESS_COLOR := Color(0.3, 1.0, 0.5)
const FAILURE_COLOR := Color(1.0, 0.35, 0.3)

@onready var player: CharacterBody2D = $Player
@onready var player_visual: Polygon2D = $Player/Visual
@onready var teammate: Polygon2D = $Teammate
@onready var off_ball_timer: ProgressBar = $Hud/OffBallTimer

var remaining_time := 0.0
var is_off_ball_active := false


func _ready() -> void:
	teammate.global_position = teammate_start_position
	off_ball_timer.max_value = off_ball_duration
	start_off_ball_situation()


func _process(delta: float) -> void:
	if not is_off_ball_active:
		return

	remaining_time = maxf(remaining_time - delta, 0.0)
	off_ball_timer.value = remaining_time
	if is_zero_approx(remaining_time):
		finish_off_ball_situation()


func start_off_ball_situation() -> void:
	player.global_position = player_start_position
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	player_visual.color = PLAYER_COLOR
	remaining_time = off_ball_duration
	off_ball_timer.value = remaining_time
	is_off_ball_active = true


func finish_off_ball_situation() -> void:
	is_off_ball_active = false
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player_visual.color = SUCCESS_COLOR if evaluate_off_ball_position_provisional() else FAILURE_COLOR
	await get_tree().create_timer(restart_interval).timeout
	start_off_ball_situation()


func evaluate_off_ball_position_provisional() -> bool:
	return player.global_position.y <= teammate.global_position.y - provisional_forward_gain
