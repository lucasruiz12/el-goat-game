extends CharacterBody2D

## Este script representa exclusivamente al jugador controlado por la persona.
## Existe para separar la logica de movimiento del armado de las escenas y facilitar
## que, mas adelante, otras reglas de gameplay no queden mezcladas aqui.
## La velocidad cambia gradualmente con move_toward(): en cada frame de fisica se
## acerca un tramo limitado al objetivo, de modo que la velocidad anterior se pierde
## de forma progresiva antes de invertir el desplazamiento.

const MOVE_LEFT := &"player_move_left"
const MOVE_RIGHT := &"player_move_right"
const MOVE_UP := &"player_move_up"
const MOVE_DOWN := &"player_move_down"
const MAX_SPEED := 240.0
const ACCELERATION := 600.0
const DECELERATION := 800.0


func _physics_process(delta: float) -> void:
	# CharacterBody2D usa velocity como velocidad en pixeles por segundo. Godot la
	# aplica al llamar move_and_slide(), que es el metodo de movimiento fisico 2D.
	var direction := Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN)
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
	else:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

	move_and_slide()
