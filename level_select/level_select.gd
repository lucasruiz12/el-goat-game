extends Control

## LevelSelect presenta el laboratorio de situaciones: una entrada por
## situación disponible, sin bloqueos de progresión. Elegir una entrada guarda
## la selección en GameProgress y abre la escena Main, que se configura con la
## SituationDefinition correspondiente. Los botones se crean desde el catálogo,
## así que una situación futura aparece sola sin tocar esta escena.

const MAIN_SCENE_PATH := "res://main.tscn"
const HOME_SCENE_PATH := "res://home/Home.tscn"
const SITUATION_BUTTON_FONT_SIZE := 24

@onready var situations_box: VBoxContainer = $SituationsBox


func _ready() -> void:
	populate_situation_buttons()


func populate_situation_buttons() -> void:
	var situations := SituationCatalog.get_all()
	var max_completed_level := GameProgress.get_max_completed_level()

	for index in situations.size():
		var situation := situations[index]
		var is_completed := index + 1 <= max_completed_level

		var button := Button.new()
		button.text = build_button_text(situation.title, is_completed)
		button.add_theme_font_size_override("font_size", SITUATION_BUTTON_FONT_SIZE)
		button.pressed.connect(start_situation.bind(index))
		situations_box.add_child(button)


func build_button_text(title: String, is_completed: bool) -> String:
	if is_completed:
		return "%s ✓" % title

	return title


func start_situation(index: int) -> void:
	# El nivel guardado sigue siendo 1-based: el dato escrito por la progresión
	# anterior sigue siendo válido y no hace falta migrar ni borrar nada.
	GameProgress.set_current_level(index + 1)
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(HOME_SCENE_PATH)
