extends "res://tests/test_case.gd"

## Pruebas de PlayerProfileCatalog: fijan la distribución aprobada de los
## cuatro perfiles (valores exactos por atributo), el contrato de rango
## [1, 100] de PlayerProfile, el presupuesto igualitario de 300 puntos y el
## comportamiento de búsqueda por id. Cualquier cambio involuntario en los
## números de equilibrio aprobados en diseño rompe estas pruebas.

## Los scripts se referencian por preload() de ruta res:// y no por su nombre
## class_name global: el runner headless no regenera
## .godot/global_script_class_cache.cfg, así que un nombre recién creado no
## compilaría hasta abrir el editor. Ver detalle en player_profile_catalog.gd.
const PlayerProfileScript = preload("res://player_profile.gd")
const PlayerProfileCatalogScript = preload("res://player_profile_catalog.gd")

const EXPECTED_ORDER := [&"creador", &"regateador", &"finalizador", &"equilibrado"]
const EXPECTED_TOTAL := 300

const EXPECTED_DISTRIBUTIONS := {
	&"creador": {
		&"velocidad": 40, &"movimiento": 56, &"vision": 64,
		&"pase": 64, &"regate": 38, &"definicion": 38,
	},
	&"regateador": {
		&"velocidad": 64, &"movimiento": 56, &"vision": 40,
		&"pase": 38, &"regate": 64, &"definicion": 38,
	},
	&"finalizador": {
		&"velocidad": 56, &"movimiento": 64, &"vision": 40,
		&"pase": 38, &"regate": 38, &"definicion": 64,
	},
	&"equilibrado": {
		&"velocidad": 50, &"movimiento": 50, &"vision": 50,
		&"pase": 50, &"regate": 50, &"definicion": 50,
	},
}


func run() -> void:
	test_catalog_contains_the_four_approved_profiles()
	test_profiles_keep_the_approved_distribution()
	test_equilibrado_is_fifty_in_every_attribute()
	test_profiles_have_valid_attributes_and_equal_budget()
	test_get_by_id_finds_profiles_and_rejects_unknown_ids()
	test_attribute_validation_rejects_broken_profiles()


func test_catalog_contains_the_four_approved_profiles() -> void:
	var profiles := PlayerProfileCatalogScript.get_all()

	check(
		profiles.size() == EXPECTED_ORDER.size(),
		"el catálogo contiene exactamente 4 perfiles (obtenido %d)" % profiles.size(),
	)

	var seen_ids := {}

	for index in EXPECTED_ORDER.size():
		var expected_id: StringName = EXPECTED_ORDER[index]
		var profile: PlayerProfileScript = profiles[index]

		check(
			profile.id == expected_id,
			"posición %d = perfil «%s» (obtenido «%s»)" % [index, expected_id, profile.id],
		)
		check(
			profile.display_name != "",
			"perfil «%s» con nombre visible no vacío" % expected_id,
		)
		check(not seen_ids.has(profile.id), "id único: %s" % profile.id)
		seen_ids[profile.id] = true


func test_profiles_keep_the_approved_distribution() -> void:
	for profile in PlayerProfileCatalogScript.get_all():
		if not EXPECTED_DISTRIBUTIONS.has(profile.id):
			check(false, "«%s» tiene distribución aprobada registrada" % profile.id)
			continue

		var expected: Dictionary = EXPECTED_DISTRIBUTIONS[profile.id]

		for key in PlayerProfileScript.ATTRIBUTE_KEYS:
			if not profile.attributes.has(key):
				check(false, "«%s» tiene el atributo «%s»" % [profile.id, key])
				continue

			check(
				profile.attributes[key] == expected[key],
				"«%s»: %s = %d (esperado %d)" % [
					profile.id, key, profile.attributes[key], expected[key],
				],
			)


func test_equilibrado_is_fifty_in_every_attribute() -> void:
	var equilibrado := PlayerProfileCatalogScript.get_by_id(PlayerProfileCatalogScript.PROFILE_ID_EQUILIBRADO)

	if equilibrado == null:
		check(false, "existe el perfil «equilibrado»")
		return

	for key in PlayerProfileScript.ATTRIBUTE_KEYS:
		check(
			equilibrado.attributes.get(key, -1) == 50,
			"Equilibrado: %s = 50 (obtenido %s)" % [key, equilibrado.attributes.get(key)],
		)


func test_profiles_have_valid_attributes_and_equal_budget() -> void:
	for profile in PlayerProfileCatalogScript.get_all():
		check(
			profile.has_valid_attributes(),
			"«%s» tiene los 6 atributos enteros en [1, 100]" % profile.id,
		)
		check(
			profile.attribute_total() == EXPECTED_TOTAL,
			"«%s» suma 300 puntos (obtenido %d)" % [profile.id, profile.attribute_total()],
		)


func test_get_by_id_finds_profiles_and_rejects_unknown_ids() -> void:
	for id in EXPECTED_ORDER:
		var profile := PlayerProfileCatalogScript.get_by_id(id)

		check(
			profile != null and profile.id == id,
			"get_by_id(«%s») devuelve el perfil correspondiente" % id,
		)

	check(PlayerProfileCatalogScript.get_by_id(&"inexistente") == null, "id desconocido devuelve null")
	check(PlayerProfileCatalogScript.get_by_id(&"") == null, "id vacío devuelve null")


func test_attribute_validation_rejects_broken_profiles() -> void:
	var valid := PlayerProfileScript.new()
	valid.attributes = make_full_attributes(50)
	check(valid.has_valid_attributes(), "6 atributos enteros en rango → perfil válido")
	check(valid.attribute_total() == EXPECTED_TOTAL, "atributos válidos suman 300")

	var missing := PlayerProfileScript.new()
	missing.attributes = {PlayerProfileScript.ATTRIBUTE_VELOCIDAD: 50}
	check(not missing.has_valid_attributes(), "faltan atributos → perfil inválido")

	var below := PlayerProfileScript.new()
	below.attributes = make_full_attributes(50)
	below.attributes[PlayerProfileScript.ATTRIBUTE_VELOCIDAD] = 0
	check(not below.has_valid_attributes(), "atributo con 0 → perfil inválido")

	var above := PlayerProfileScript.new()
	above.attributes = make_full_attributes(50)
	above.attributes[PlayerProfileScript.ATTRIBUTE_PASE] = 101
	check(not above.has_valid_attributes(), "atributo con 101 → perfil inválido")

	var not_integer := PlayerProfileScript.new()
	not_integer.attributes = make_full_attributes(50)
	not_integer.attributes[PlayerProfileScript.ATTRIBUTE_REGATE] = 50.5
	check(not not_integer.has_valid_attributes(), "atributo no entero → perfil inválido")


func make_full_attributes(value: int) -> Dictionary:
	return {
		PlayerProfileScript.ATTRIBUTE_VELOCIDAD: value,
		PlayerProfileScript.ATTRIBUTE_MOVIMIENTO: value,
		PlayerProfileScript.ATTRIBUTE_VISION: value,
		PlayerProfileScript.ATTRIBUTE_PASE: value,
		PlayerProfileScript.ATTRIBUTE_REGATE: value,
		PlayerProfileScript.ATTRIBUTE_DEFINICION: value,
	}
