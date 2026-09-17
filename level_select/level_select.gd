extends Control

## Level Select presenta los niveles disponibles y decide a qué escena entrar.
## También refleja visualmente el progreso: un nivel completado muestra ✓,
## uno desbloqueado queda disponible sin candado y uno bloqueado mantiene 🔒.


@onready var level_1_button: Button = $Level1Button
@onready var level_2_button: Button = $Level2Button
@onready var level_3_button: Button = $Level3Button
@onready var level_4_button: Button = $Level4Button


func _ready() -> void:
	update_level_buttons()


func update_level_buttons() -> void:
	var max_unlocked_level := GameProgress.get_max_unlocked_level()
	var max_completed_level := GameProgress.get_max_completed_level()

	update_level_button(level_1_button, 1, max_unlocked_level, max_completed_level)
	update_level_button(level_2_button, 2, max_unlocked_level, max_completed_level)
	update_level_button(level_3_button, 3, max_unlocked_level, max_completed_level)
	update_level_button(level_4_button, 4, max_unlocked_level, max_completed_level)


func update_level_button(
	button: Button,
	level: int,
	max_unlocked_level: int,
	max_completed_level: int,
) -> void:
	button.disabled = level > max_unlocked_level

	if level <= max_completed_level:
		button.text = "NIVEL %d ✓" % level
	elif level <= max_unlocked_level:
		button.text = "NIVEL %d" % level
	else:
		button.text = "NIVEL %d 🔒" % level


func _on_level_1_pressed() -> void:
	start_level(1)


func _on_level_2_pressed() -> void:
	start_level(2)


func _on_level_3_pressed() -> void:
	start_level(3)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://home/Home.tscn")


func start_level(level: int) -> void:
	GameProgress.set_current_level(level)
	get_tree().change_scene_to_file("res://main.tscn")