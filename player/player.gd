extends CharacterBody2D

## Este script representa exclusivamente al jugador controlado por la persona.
## Existe para separar la logica de movimiento del armado de las escenas y facilitar
## que, mas adelante, otras reglas de gameplay no queden mezcladas aqui.

const MOVE_LEFT := &"player_move_left"
const MOVE_RIGHT := &"player_move_right"
const MOVE_UP := &"player_move_up"
const MOVE_DOWN := &"player_move_down"
const SPEED := 240.0


func _physics_process(_delta: float) -> void:
	# CharacterBody2D usa velocity como velocidad en pixeles por segundo. Godot la
	# aplica al llamar move_and_slide(), que es el metodo de movimiento fisico 2D.
	var direction := Input.get_vector(MOVE_LEFT, MOVE_RIGHT, MOVE_UP, MOVE_DOWN)
	velocity = direction * SPEED

	move_and_slide()
