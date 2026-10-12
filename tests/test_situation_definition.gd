extends "res://tests/test_case.gd"

## Pruebas de SituationDefinition: protegen los valores por defecto que toda
## situación nueva hereda del Resource. Hoy cubre la cantidad de rivales, que
## main.gd usa para instanciar entidades en el campo.

func run() -> void:
	test_fresh_definition_defaults_to_one_rival()


func test_fresh_definition_defaults_to_one_rival() -> void:
	var definition := SituationDefinition.new()

	check(
		definition.rival_count == 1,
		"una definición nueva tiene rival_count = 1 (obtenido %d)" % definition.rival_count
	)
