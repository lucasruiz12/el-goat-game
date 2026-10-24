class_name PlayerProfileCatalog
extends RefCounted

## PlayerProfileCatalog lista los perfiles iniciales en orden estable y
## funciona como única puerta de entrada a ellos, igual que SituationCatalog
## con las situaciones: el creador (más adelante) recorre get_all() para
## ofrecer la selección y SessionPlayer pide un perfil por id al crear la
## sesión. Añadir un perfil futuro consiste en su función constructora y una
## línea en get_all().
##
## Las distribuciones son las aprobadas en el diseño: mismo presupuesto
## (300 puntos) en los cuatro perfiles y especialización moderada. Los
## valores son fijos y deterministas; no hay aleatoriedad de ningún tipo.
##
## get_all() construye perfiles nuevos en cada llamada (como hace
## SituationCatalog): el catálogo no es estado compartido y mutar una
## instancia no afecta a la siguiente consulta.
##
## Los nombres display_name son texto visible todavía sin traducir: cuando
## exista localización real convendrá moverlos a los archivos de traducción
## de Godot en lugar de dispersarlos por el código.

## Los scripts del modelo se referencian con preload() por ruta res:// y no
## por su nombre class_name global. Motivo: los nombres class_name se
## resuelven contra .godot/global_script_class_cache.cfg, que únicamente
## genera el escaneo del editor; el runner de pruebas (godot --headless -s)
## no lo actualiza, así que un class_name recién creado no compila en la
## suite hasta abrir el editor. preload() resuelve por ruta en tiempo de
## compilación y no depende de ese caché. Es el mismo patrón que ya usa
## main.gd (FieldScript, RivalScript, SituationEvaluatorScript, etc.).
const PlayerProfileScript = preload("res://player_profile.gd")

const PROFILE_ID_CREADOR := &"creador"
const PROFILE_ID_REGATEADOR := &"regateador"
const PROFILE_ID_FINALIZADOR := &"finalizador"
const PROFILE_ID_EQUILIBRADO := &"equilibrado"

const EXPECTED_ATTRIBUTE_TOTAL := 300


static func get_all() -> Array[PlayerProfileScript]:
	return [
		_build_creador(),
		_build_regateador(),
		_build_finalizador(),
		_build_equilibrado(),
	]


static func get_by_id(id: StringName) -> PlayerProfileScript:
	for profile in get_all():
		if profile.id == id:
			return profile

	# A diferencia de SituationCatalog.get_by_index (que recorta para que un
	# save viejo no rompa el arranque), el id de perfil es un dato explícito
	# del creador o de una sesión: si no existe, devolver null permite
	# rechazarlo con un mensaje claro.
	return null


static func _build_creador() -> PlayerProfileScript:
	return _build_profile(PROFILE_ID_CREADOR, "Creador", 40, 56, 64, 64, 38, 38)


static func _build_regateador() -> PlayerProfileScript:
	return _build_profile(PROFILE_ID_REGATEADOR, "Regateador", 64, 56, 40, 38, 64, 38)


static func _build_finalizador() -> PlayerProfileScript:
	return _build_profile(PROFILE_ID_FINALIZADOR, "Finalizador", 56, 64, 40, 38, 38, 64)


static func _build_equilibrado() -> PlayerProfileScript:
	return _build_profile(PROFILE_ID_EQUILIBRADO, "Equilibrado", 50, 50, 50, 50, 50, 50)


static func _build_profile(
	id: StringName,
	display_name: String,
	velocidad: int,
	movimiento: int,
	vision: int,
	pase: int,
	regate: int,
	definicion: int,
) -> PlayerProfileScript:
	var profile := PlayerProfileScript.new()
	profile.id = id
	profile.display_name = display_name
	profile.attributes = {
		PlayerProfileScript.ATTRIBUTE_VELOCIDAD: velocidad,
		PlayerProfileScript.ATTRIBUTE_MOVIMIENTO: movimiento,
		PlayerProfileScript.ATTRIBUTE_VISION: vision,
		PlayerProfileScript.ATTRIBUTE_PASE: pase,
		PlayerProfileScript.ATTRIBUTE_REGATE: regate,
		PlayerProfileScript.ATTRIBUTE_DEFINICION: definicion,
	}
	return profile
