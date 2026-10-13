extends "res://tests/test_case.gd"

## Pruebas de SituationCatalog: protegen el contrato que usan el laboratorio y
## main.gd. Fijan (1) que toda situación tiene identidad y título, (2) que
## pedir un índice fuera de rango nunca falla y devuelve una situación válida
## (un save viejo no puede romper el arranque) y (3) los parámetros exactos de
## la Situación 1, para detectar cambios involuntarios de equilibrio.

const DESMARQUE_ID := &"desmarque_presion"


func run() -> void:
	test_catalog_situations_have_identity()
	test_get_by_index_clamps_out_of_range_values()
	test_desmarque_situation_keeps_situation_1_parameters()


func test_catalog_situations_have_identity() -> void:
	var situations := SituationCatalog.get_all()

	check(situations.size() > 0, "el catálogo contiene al menos una situación")

	var seen_ids := {}
	for situation in situations:
		check(situation.id != &"", "situación con id no vacío")
		check(situation.title != "", "situación «%s» con título no vacío" % situation.title)
		check(not seen_ids.has(situation.id), "id único: %s" % situation.id)
		seen_ids[situation.id] = true


func test_get_by_index_clamps_out_of_range_values() -> void:
	var situations := SituationCatalog.get_all()
	var first := situations[0]
	var last := situations[situations.size() - 1]

	check(SituationCatalog.get_by_index(-5).id == first.id, "índice -5 devuelve la primera situación")
	check(SituationCatalog.get_by_index(999).id == last.id, "índice 999 devuelve la última situación")


func test_desmarque_situation_keeps_situation_1_parameters() -> void:
	var situation := find_situation(DESMARQUE_ID)

	if situation == null:
		check(false, "existe la situación «desmarque_presion»")
		return

	check(true, "existe la situación «desmarque_presion»")
	check_approx(situation.off_ball_duration, 2.0, "duración del desmarque")
	check_approx(situation.restart_interval, 1.0, "intervalo de reinicio")
	check_approx(situation.ball_speed, 350.0, "velocidad del pase")
	check_approx(situation.teammate_pass_precision, 0.72, "precisión del pase")
	check_approx(situation.pass_lead_distance, 72.0, "distancia de adelanto del pase")
	check_approx(situation.maximum_pass_error, 80.0, "error máximo del pase")
	check_approx(situation.ball_contact_distance, 25.0, "distancia de contacto con la pelota")
	check_approx(situation.ball_outside_grace_duration, 0.5, "gracia de pelota fuera")
	check_approx(situation.rival_speed, 115.0, "velocidad del rival")
	check_approx(situation.minimum_initial_rival_distance, 150.0, "distancia mínima inicial del rival")
	check(situation.rival_count == 1, "cantidad de rivales = 1 (obtenido %d)" % situation.rival_count)
	check_approx(situation.holder_shift_distance, 0.0, "desplazamiento del poseedor = 0 (estático)")
	check_approx(situation.holder_shift_speed, 60.0, "velocidad del desplazamiento del poseedor")
	check(
		situation.player_start_region == Rect2(0.35, 0.75, 0.30, 0.16),
		"región inicial del jugador"
	)
	check(
		situation.teammate_start_region == Rect2(0.33, 0.55, 0.34, 0.17),
		"región inicial del compañero"
	)
	check(
		situation.rival_start_region == Rect2(0.30, 0.18, 0.40, 0.28),
		"región inicial del rival"
	)


func find_situation(id: StringName) -> SituationDefinition:
	for situation in SituationCatalog.get_all():
		if situation.id == id:
			return situation

	return null
