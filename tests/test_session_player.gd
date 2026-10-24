extends "res://tests/test_case.gd"

## Pruebas de SessionPlayer: creación de la sesión (datos personales,
## atributos copiados del perfil sin compartir el diccionario del catálogo),
## rechazo de datos inválidos, limpieza explícita y la fórmula pura de
## velocidad máxima aprobada en diseño (240 px/s con Velocidad = 50, el
## comportamiento actual del juego).
##
## SessionPlayer guarda estado en una variable estática que persiste mientras
## vive el proceso: cada grupo limpia la sesión antes y después para que los
## resultados no dependan del orden alfabético en que el runner ejecute los
## archivos.

## Los scripts se referencian por preload() de ruta res:// y no por su nombre
## class_name global: el runner headless no regenera
## .godot/global_script_class_cache.cfg, así que un nombre recién creado no
## compilaría hasta abrir el editor. Ver detalle en player_profile_catalog.gd.
const PlayerProfileScript = preload("res://player_profile.gd")
const PlayerProfileCatalogScript = preload("res://player_profile_catalog.gd")
const SessionPlayerScript = preload("res://session_player.gd")

const LEO_NAME := "Leo"
const LEO_SURNAME := "Fernández"
const LEO_SHIRT := 10
# Id fijado como literal (mismo criterio que DESMARQUE_ID en
# test_situation_catalog.gd): si el catálogo renombra el perfil, la prueba
# falla en lugar de seguir el cambio sin avisar.
const EQUILIBRADO_ID := &"equilibrado"


func run() -> void:
	test_create_stores_personal_data_and_profile_id()
	test_create_copies_attributes_without_sharing_the_catalog_dictionary()
	test_create_rejects_empty_names_and_surnames_after_strip()
	test_create_rejects_shirt_numbers_outside_the_allowed_range()
	test_create_rejects_unknown_profiles()
	test_clear_resets_the_session_to_null()
	test_movement_max_speed_matches_the_approved_formula()


func test_create_stores_personal_data_and_profile_id() -> void:
	SessionPlayerScript.clear()

	var session := SessionPlayerScript.create("  " + LEO_NAME + "  ", LEO_SURNAME, LEO_SHIRT, EQUILIBRADO_ID)

	check(session != null, "create() devuelve una sesión con datos válidos")

	if session == null:
		return

	check(session == SessionPlayerScript.current, "la sesión creada queda activa en current")
	check(session.player_name == LEO_NAME, "el nombre se guarda sin espacios sobrantes")
	check(session.surname == LEO_SURNAME, "el apellido se guarda tal cual")
	check(session.shirt_number == LEO_SHIRT, "el número de camiseta se guarda tal cual")
	check(session.profile_id == EQUILIBRADO_ID, "el id del perfil elegido se guarda tal cual")

	SessionPlayerScript.clear()


func test_create_copies_attributes_without_sharing_the_catalog_dictionary() -> void:
	SessionPlayerScript.clear()

	var profile := PlayerProfileCatalogScript.get_by_id(EQUILIBRADO_ID)

	if profile == null:
		check(false, "existe el perfil «equilibrado» en el catálogo")
		return

	var session := SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, LEO_SHIRT, EQUILIBRADO_ID)

	if session == null:
		check(false, "create() devuelve una sesión para el perfil equilibrado")
		return

	check(
		session.attributes.size() == PlayerProfileScript.ATTRIBUTE_KEYS.size(),
		"la sesión copia los 6 atributos del perfil",
	)

	for key in PlayerProfileScript.ATTRIBUTE_KEYS:
		check(
			session.attributes.get(key) == profile.attributes.get(key),
			"«%s» copiado del perfil (esperado %d, obtenido %s)" % [
				key, profile.attributes.get(key, -1), session.attributes.get(key),
			],
		)

	session.attributes[PlayerProfileScript.ATTRIBUTE_VELOCIDAD] = 1

	check(
		profile.attributes.get(PlayerProfileScript.ATTRIBUTE_VELOCIDAD) == 50,
		"mutar la sesión no modifica los atributos del perfil del catálogo",
	)

	var second_session := SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, LEO_SHIRT, EQUILIBRADO_ID)

	if second_session == null:
		check(false, "create() permite crear una segunda sesión")
		return

	check(
		second_session.attributes.get(PlayerProfileScript.ATTRIBUTE_VELOCIDAD) == 50,
		"una sesión posterior recibe los valores originales del perfil",
	)

	SessionPlayerScript.clear()


func test_create_rejects_empty_names_and_surnames_after_strip() -> void:
	SessionPlayerScript.clear()

	check(
		SessionPlayerScript.create("", LEO_SURNAME, LEO_SHIRT, EQUILIBRADO_ID) == null,
		"nombre vacío rechazado",
	)
	check(
		SessionPlayerScript.create("   ", LEO_SURNAME, LEO_SHIRT, EQUILIBRADO_ID) == null,
		"nombre solo con espacios rechazado",
	)
	check(
		SessionPlayerScript.create(LEO_NAME, "", LEO_SHIRT, EQUILIBRADO_ID) == null,
		"apellido vacío rechazado",
	)
	check(
		SessionPlayerScript.create(LEO_NAME, "   ", LEO_SHIRT, EQUILIBRADO_ID) == null,
		"apellido solo con espacios rechazado",
	)
	check(SessionPlayerScript.current == null, "ninguna sesión inválida queda activa")

	SessionPlayerScript.clear()


func test_create_rejects_shirt_numbers_outside_the_allowed_range() -> void:
	SessionPlayerScript.clear()

	check(
		SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, 0, EQUILIBRADO_ID) == null,
		"camiseta 0 rechazada",
	)
	check(
		SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, 100, EQUILIBRADO_ID) == null,
		"camiseta 100 rechazada",
	)
	check(
		SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, -5, EQUILIBRADO_ID) == null,
		"camiseta negativa rechazada",
	)
	check(SessionPlayerScript.current == null, "ninguna sesión inválida queda activa")

	var lower_edge := SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, 1, EQUILIBRADO_ID)
	check(lower_edge != null, "camiseta 1 aceptada (límite inferior)")

	var upper_edge := SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, 99, EQUILIBRADO_ID)
	check(upper_edge != null, "camiseta 99 aceptada (límite superior)")

	SessionPlayerScript.clear()


func test_create_rejects_unknown_profiles() -> void:
	SessionPlayerScript.clear()

	check(
		SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, LEO_SHIRT, &"inexistente") == null,
		"perfil inexistente rechazado",
	)
	check(
		SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, LEO_SHIRT, &"") == null,
		"perfil con id vacío rechazado",
	)
	check(SessionPlayerScript.current == null, "ningún perfil inválido deja sesión activa")

	SessionPlayerScript.clear()


func test_clear_resets_the_session_to_null() -> void:
	SessionPlayerScript.clear()

	var session := SessionPlayerScript.create(LEO_NAME, LEO_SURNAME, LEO_SHIRT, EQUILIBRADO_ID)

	check(session != null and SessionPlayerScript.current != null, "hay una sesión activa tras create()")

	SessionPlayerScript.clear()

	check(SessionPlayerScript.current == null, "clear() devuelve current a null")


func test_movement_max_speed_matches_the_approved_formula() -> void:
	check_approx(SessionPlayerScript.movement_max_speed(50), 240.0, "Velocidad 50 = 240 px/s (velocidad actual)")
	check_approx(SessionPlayerScript.movement_max_speed(1), 151.8, "Velocidad 1 = 151.8 px/s")
	check_approx(SessionPlayerScript.movement_max_speed(100), 330.0, "Velocidad 100 = 330 px/s")

	var is_monotonic := true
	var previous := SessionPlayerScript.movement_max_speed(1)

	for velocidad in range(2, 101):
		var current := SessionPlayerScript.movement_max_speed(velocidad)

		if current <= previous:
			is_monotonic = false
			break

		previous = current

	check(is_monotonic, "la velocidad máxima crece de forma estrictamente monótona (1 a 100)")
