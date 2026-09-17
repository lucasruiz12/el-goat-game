class_name GameProgress
extends RefCounted

## GameProgress centraliza el progreso mínimo del juego.
## Guardamos hasta qué nivel fue completado y, a partir de eso, qué niveles están
## disponibles. El progreso vive en user:// para mantenerse entre ejecuciones.


const SAVE_PATH := "user://progress.cfg"
const SECTION := "progress"
const MAX_UNLOCKED_LEVEL_KEY := "max_unlocked_level"
const MAX_COMPLETED_LEVEL_KEY := "max_completed_level"
const CURRENT_LEVEL_KEY := "current_level"


static func get_max_unlocked_level() -> int:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)

	if error != OK:
		return 1

	return maxi(int(config.get_value(SECTION, MAX_UNLOCKED_LEVEL_KEY, 1)), 1)


static func get_max_completed_level() -> int:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)

	if error != OK:
		return 0

	# Compatibilidad con el progreso que ya habíamos guardado:
	# si Nivel 2 está desbloqueado pero todavía no existe el dato de completados,
	# significa que el Nivel 1 ya fue completado.
	var completed_level := int(config.get_value(SECTION, MAX_COMPLETED_LEVEL_KEY, -1))

	if completed_level >= 0:
		return maxi(completed_level, 0)

	var max_unlocked_level := maxi(
		int(config.get_value(SECTION, MAX_UNLOCKED_LEVEL_KEY, 1)),
		1,
	)

	return max_unlocked_level - 1


static func set_current_level(level: int) -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	config.set_value(SECTION, CURRENT_LEVEL_KEY, level)
	config.save(SAVE_PATH)


static func get_current_level() -> int:
	var config := ConfigFile.new()
	var error := config.load(SAVE_PATH)

	if error != OK:
		return 1

	return maxi(int(config.get_value(SECTION, CURRENT_LEVEL_KEY, 1)), 1)


static func complete_current_level() -> void:
	var current_level := get_current_level()
	var max_completed_level := get_max_completed_level()

	if current_level > max_completed_level:
		max_completed_level = current_level

	var max_unlocked_level := maxi(
		get_max_unlocked_level(),
		max_completed_level + 1,
	)

	# El Nivel 4 no forma parte de esta progresión todavía.
	max_unlocked_level = mini(max_unlocked_level, 3)

	var config := ConfigFile.new()
	config.load(SAVE_PATH)

	config.set_value(SECTION, MAX_COMPLETED_LEVEL_KEY, max_completed_level)
	config.set_value(SECTION, MAX_UNLOCKED_LEVEL_KEY, max_unlocked_level)
	config.save(SAVE_PATH)