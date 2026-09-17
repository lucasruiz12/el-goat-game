class_name Ball
extends Node2D

## Ball representa una pelota independiente de los jugadores. Main decide cuando
## empieza un pase y hacia que zona apunta; esta escena administra la trayectoria
## y la perdida constante de velocidad producida por el rozamiento con el piso.
## El punto objetivo del pase no es un destino donde la pelota deba detenerse:
## la pelota mantiene su trayectoria y continua hasta perder toda su velocidad.

signal pass_finished

@export var radius := 8.0
@export var deceleration := 120.0

var destination := Vector2.ZERO
var velocity := Vector2.ZERO
var is_moving := false


func _ready() -> void:
	configure_visual()


func _process(delta: float) -> void:
	if not is_moving:
		return

	global_position += velocity * delta

	# La velocidad pierde siempre la misma cantidad por segundo.
	# Esto representa una desaceleracion constante por rozamiento.
	var current_speed := velocity.length()
	current_speed = move_toward(current_speed, 0.0, deceleration * delta)

	if current_speed <= 0.0:
		velocity = Vector2.ZERO
		is_moving = false
		pass_finished.emit()
		return

	velocity = velocity.normalized() * current_speed


func start_pass(origin: Vector2, target: Vector2, pass_speed: float) -> void:
	global_position = origin
	destination = target

	var pass_direction := origin.direction_to(target)
	velocity = pass_direction * pass_speed

	is_moving = true
	visible = true


func reset_at(position: Vector2) -> void:
	global_position = position
	destination = position
	velocity = Vector2.ZERO
	is_moving = false
	visible = true


func stop_at(position: Vector2) -> void:
	global_position = position
	destination = position
	velocity = Vector2.ZERO
	is_moving = false


func configure_visual() -> void:
	var points := PackedVector2Array()
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	$Visual.polygon = points