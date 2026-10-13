class_name Teammate
extends Node2D

## Teammate representa al compañero que tiene la pelota. Main decide dónde se
## coloca, cuándo comienza a desplazarse hacia su punto de apoyo y cuándo se
## ejecuta el pase; la pelota nace en su posición. El script existe para darle
## identidad propia reutilizable (igual que Rival y Ball) en vez de depender de
## un nodo anónimo de la escena Main.


func move_toward_target(target_position: Vector2, speed: float, delta: float) -> void:
	global_position = global_position.move_toward(target_position, speed * delta)
