extends Control

## Home es la pantalla inicial del juego.
## Su responsabilidad es presentar la identidad de EL GOAT y ofrecer la entrada
## al siguiente paso del flujo: la selección de niveles.
##
## Usamos Control porque esta pantalla está compuesta por elementos de interfaz
## (botones, textos, contenedores) y no por objetos del mundo del juego.
## La navegación se mantiene acá para que Main no tenga que conocer los detalles
## visuales de la Home.


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://level_select/LevelSelect.tscn")