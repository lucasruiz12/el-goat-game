extends "res://tests/test_case.gd"

## Pruebas de integración de T5 en main.gd: funciones puras que unen la
## calidad de la línea con la precisión del pase, deciden intercepciones y
## asignan mensajes de resultado. Sin escena principal ni RNG.

const MainScript = preload("res://main.gd")

const PASS_PRECISION := 0.72
const INTERCEPTION_RANGE := 15.0


func run() -> void:
	test_free_lane_keeps_precision()
	test_committed_lane_reduces_precision_gradually()
	test_effective_precision_stays_bounded()
	test_interception_requires_proximity_threshold()
	test_interception_ignores_distant_rivals()
	test_interception_without_rivals()
	test_outcome_messages_are_distinct()
	test_only_precise_outcome_is_success()


func test_free_lane_keeps_precision() -> void:
	var combined: float = MainScript.combine_precision_with_lane(PASS_PRECISION, 1.0)

	check_approx(combined, PASS_PRECISION, "con la línea despejada la precisión no cambia")


func test_committed_lane_reduces_precision_gradually() -> void:
	var half_lane: float = MainScript.combine_precision_with_lane(PASS_PRECISION, 0.5)
	var worse_lane: float = MainScript.combine_precision_with_lane(PASS_PRECISION, 0.25)

	check_approx(half_lane, PASS_PRECISION * 0.5, "con la línea a media claridad la precisión baja a la mitad")
	check(worse_lane < half_lane, "una línea más comprometida reduce más la precisión")


func test_effective_precision_stays_bounded() -> void:
	check_approx(MainScript.combine_precision_with_lane(PASS_PRECISION, 0.0), 0.0, "línea bloqueada = precisión efectiva 0")
	check_approx(MainScript.combine_precision_with_lane(2.0, 1.0), 1.0, "la precisión efectiva queda acotada a 1")


func test_interception_requires_proximity_threshold() -> void:
	var ball := Vector2.ZERO
	var near_rivals: Array[Vector2] = [Vector2(12.0, 0.0)]
	var shadow_rivals: Array[Vector2] = [Vector2(20.0, 0.0)]

	check(
		MainScript.is_ball_intercepted_at(ball, near_rivals, INTERCEPTION_RANGE),
		"un rival dentro del umbral de intercepción intercepta",
	)
	check(
		not MainScript.is_ball_intercepted_at(ball, shadow_rivals, INTERCEPTION_RANGE),
		"un rival cerca pero fuera del umbral no intercepta automáticamente",
	)


func test_interception_ignores_distant_rivals() -> void:
	var distant_rivals: Array[Vector2] = [Vector2(300.0, 0.0)]

	check(
		not MainScript.is_ball_intercepted_at(Vector2.ZERO, distant_rivals, INTERCEPTION_RANGE),
		"un rival lejano no intercepta",
	)


func test_interception_without_rivals() -> void:
	var no_rivals: Array[Vector2] = []

	check(
		not MainScript.is_ball_intercepted_at(Vector2.ZERO, no_rivals, INTERCEPTION_RANGE),
		"sin rivales no hay intercepción",
	)


func test_outcome_messages_are_distinct() -> void:
	var precise: String = MainScript.get_pass_outcome_message(MainScript.PassOutcome.PRECISE)
	var deviated: String = MainScript.get_pass_outcome_message(MainScript.PassOutcome.DEVIATED)
	var intercepted: String = MainScript.get_pass_outcome_message(MainScript.PassOutcome.INTERCEPTED)

	check(
		precise != deviated and precise != intercepted and deviated != intercepted,
		"los tres resultados tienen mensajes distintos, sin resultados contradictorios",
	)


func test_only_precise_outcome_is_success() -> void:
	check(MainScript.is_pass_successful(MainScript.PassOutcome.PRECISE), "el pase preciso es el único resultado exitoso")
	check(not MainScript.is_pass_successful(MainScript.PassOutcome.DEVIATED), "el pase desviado no es exitoso")
	check(not MainScript.is_pass_successful(MainScript.PassOutcome.INTERCEPTED), "el pase interceptado no es exitoso")
