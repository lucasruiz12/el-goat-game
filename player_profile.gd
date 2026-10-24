class_name PlayerProfile
extends RefCounted

## PlayerProfile representa un perfil inicial del jugador: una distribución
## fija y determinista de los seis atributos, construida en código desde
## PlayerProfileCatalog (mismo patrón que SituationDefinition con
## SituationCatalog). Usa RefCounted en vez de Resource porque es puro dato
## construido en código: no necesita inspector ni archivos .tres todavía;
## conviene migrarlo si algún día los perfiles se editan desde el editor.
##
## Separa dos capas de datos: el perfil es solo el reparto de atributos y el
## jugador de la sesión (SessionPlayer) es quien guarda los datos personales.
## Así un mismo perfil puede usarse en muchas sesiones sin que ninguna lo
## modifique.

const ATTRIBUTE_MIN := 1
const ATTRIBUTE_MAX := 100

# Claves de atributo como StringName para no dispersar strings mágicos por
# el modelo, las pruebas y (más adelante) el creador y el gameplay.
const ATTRIBUTE_VELOCIDAD := &"velocidad"
const ATTRIBUTE_MOVIMIENTO := &"movimiento"
const ATTRIBUTE_VISION := &"vision"
const ATTRIBUTE_PASE := &"pase"
const ATTRIBUTE_REGATE := &"regate"
const ATTRIBUTE_DEFINICION := &"definicion"

const ATTRIBUTE_KEYS := [
	ATTRIBUTE_VELOCIDAD,
	ATTRIBUTE_MOVIMIENTO,
	ATTRIBUTE_VISION,
	ATTRIBUTE_PASE,
	ATTRIBUTE_REGATE,
	ATTRIBUTE_DEFINICION,
]


var id: StringName = &""
var display_name := ""
var attributes: Dictionary = {}


## has_valid_attributes comprueba el contrato mínimo de un perfil: los seis
## atributos presentes, todos enteros y dentro de [1, 100]. No valida el
## presupuesto total: esa regla de diseño (300 puntos) pertenece a los
## perfiles iniciales del catálogo y la fijan sus pruebas.
func has_valid_attributes() -> bool:
	for key in ATTRIBUTE_KEYS:
		if not attributes.has(key):
			return false

		var value = attributes[key]

		if typeof(value) != TYPE_INT:
			return false

		if value < ATTRIBUTE_MIN or value > ATTRIBUTE_MAX:
			return false

	return true


func attribute_total() -> int:
	var total := 0

	for value in attributes.values():
		total += value

	return total
