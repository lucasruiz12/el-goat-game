class_name SituationCatalog
extends RefCounted

## SituationCatalog lista las situaciones del laboratorio en orden estable.
## Funciona como única puerta de entrada al catálogo: el selector recorre la
## lista para mostrar sus entradas y Main pide una definición por índice.
## Añadir una situación futura consiste en crear su función constructora y
## añadirla a get_all(); ni el selector ni Main necesitan cambios.
##
## El título es texto visible todavía sin traducir: cuando exista localización
## real convendrá moverlo a los archivos de traducción de Godot en lugar de
## dispersarlo por el código.

const SITUATION_ID_DESMARQUE_PRESION := &"desmarque_presion"


static func get_all() -> Array[SituationDefinition]:
	return [_build_desmarque_presion()]


static func get_by_index(index: int) -> SituationDefinition:
	var situations := get_all()
	return situations[clampi(index, 0, situations.size() - 1)]


static func _build_desmarque_presion() -> SituationDefinition:
	var situation := SituationDefinition.new()
	situation.id = SITUATION_ID_DESMARQUE_PRESION
	situation.title = "Desmarque con presión"
	situation.off_ball_duration = 2.0
	situation.restart_interval = 1.0
	situation.ball_speed = 350.0
	situation.teammate_pass_precision = 0.72
	situation.pass_lead_distance = 72.0
	situation.maximum_pass_error = 80.0
	situation.ball_contact_distance = 25.0
	situation.ball_outside_grace_duration = 0.5
	situation.rival_count = 1
	situation.rival_speed = 115.0
	situation.minimum_initial_rival_distance = 150.0
	situation.player_start_region = Rect2(0.35, 0.75, 0.30, 0.16)
	situation.teammate_start_region = Rect2(0.33, 0.55, 0.34, 0.17)
	situation.rival_start_region = Rect2(0.30, 0.18, 0.40, 0.28)
	return situation
