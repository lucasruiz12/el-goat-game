class_name Rival
extends Node2D

## Rival implementa presion minima para esta iteracion: se acerca al jugador a una
## velocidad configurable. No decide marcajes ni tacticas; mantener ese movimiento
## aqui permite que Main coordine la secuencia sin conocer como se desplaza el rival.

func apply_pressure(target_position: Vector2, speed: float, delta: float) -> void:
	global_position = global_position.move_toward(target_position, speed * delta)
