class_name SessionPlayer
extends RefCounted

## SessionPlayer es el jugador creado en el creador y usado por todas las
## situaciones de la sesión. Es el primer archivo del proyecto con estado de
## sesión en memoria, así que explica el concepto:
##
## - `current` es una variable estática de la clase: sobrevive a los cambios
##   de escena (change_scene_to_file destruye las escenas, pero el script ya
##   cargado permanece en memoria durante todo el proceso del juego) y muere
##   al salir del juego. Esa es exactamente la semántica pedida: una sesión,
##   un jugador; reiniciar el juego vuelve al creador.
## - No hay autoload ni persistencia en disco: el patrón de clases estáticas
##   ya lo usa GameProgress para el progreso de situaciones, y a diferencia
##   de GameProgress (que escribe en user://) esto es memoria pura, así que
##   se puede testear con el runner headless.
## - SessionPlayer y GameProgress no se mezclan: uno guarda quién es el
##   jugador de la sesión; el otro, el avance en el laboratorio.
##
## Los atributos se copian del perfil al crear la sesión (duplicate()): la
## sesión es dueña de sus valores, de modo que cuando exista progresión de
## atributos se podrán modificar sin tocar el catálogo original.
##
## La fórmula de velocidad aprobada vive acá como función pura para poder
## testearla sin escenas; la integra en player/player.gd una fase posterior.
## Con Velocidad = 50 devuelve 240 px/s, la velocidad máxima actual: el
## perfil Equilibrado debe sentirse idéntico al juego de hoy.

## Referencia por preload() y no por el nombre class_name global: ver la
## explicación en player_profile_catalog.gd (el caché de clases globales solo
## lo genera el editor y el runner headless no lo actualiza).
const PlayerProfileCatalogScript = preload("res://player_profile_catalog.gd")

const SHIRT_NUMBER_MIN := 1
const SHIRT_NUMBER_MAX := 99

const BASE_MAX_SPEED := 150.0
const MAX_SPEED_PER_VELOCIDAD_POINT := 1.8

static var current: SessionPlayer = null

var player_name := ""
var surname := ""
var shirt_number := 0
var profile_id: StringName = &""
var attributes: Dictionary = {}


## create() valida los datos personales y el perfil, y solo entonces construye
## la sesión y la deja activa en `current`. Devuelve null sin tocar la sesión
## existente si algo es inválido. Los nombres se guardan sin espacios
## sobrantes.
static func create(
	new_player_name: String,
	new_surname: String,
	new_shirt_number: int,
	new_profile_id: StringName,
) -> SessionPlayer:
	if not is_valid_name(new_player_name):
		return null

	if not is_valid_name(new_surname):
		return null

	if not is_valid_shirt_number(new_shirt_number):
		return null

	var profile := PlayerProfileCatalogScript.get_by_id(new_profile_id)

	if profile == null:
		return null

	var session := SessionPlayer.new()
	session.player_name = new_player_name.strip_edges()
	session.surname = new_surname.strip_edges()
	session.shirt_number = new_shirt_number
	session.profile_id = new_profile_id
	session.attributes = profile.attributes.duplicate()

	current = session
	return session


## clear() termina la sesión explícitamente: la usan las pruebas para
## determinismo y servirá si algún día existe un reinicio de partida dentro
## del mismo proceso.
static func clear() -> void:
	current = null


static func is_valid_name(value: String) -> bool:
	return not value.strip_edges().is_empty()


static func is_valid_shirt_number(value: int) -> bool:
	return value >= SHIRT_NUMBER_MIN and value <= SHIRT_NUMBER_MAX


static func movement_max_speed(velocidad: int) -> float:
	return BASE_MAX_SPEED + MAX_SPEED_PER_VELOCIDAD_POINT * float(velocidad)
