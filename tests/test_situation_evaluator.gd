extends "res://tests/test_case.gd"

## Pruebas de SituationEvaluator: matemática del pase con RNG sembrado para
## ser deterministas. Protegen (1) que sin error el destino es exactamente el
## punto adelantado, (2) que un error enorme nunca saca el destino de la zona
## segura de la cancha y (3) que la calidad separa peor/mejor según la
## distancia del rival, además de permanecer en [0, 1].

const FIELD_RECT := Rect2(0.0, 0.0, 960.0, 540.0)
const SAFE_RECT := Rect2(24.0, 24.0, 912.0, 492.0)  # FIELD_RECT.grow(-24.0)
const SEEDED_SEED := 12345

const PLAYER_POSITION := Vector2(480.0, 300.0)
const PLAYER_VELOCITY := Vector2(1.0, 0.0)
const TEAMMATE_POSITION := Vector2(600.0, 200.0)
const LEAD_DISTANCE := 72.0


func run() -> void:
	test_pass_target_matches_lead_point_without_error()
	test_pass_target_stays_inside_safe_area_with_hostile_error()
	test_quality_increases_when_rival_is_closer()


func make_rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = SEEDED_SEED
	return rng


func test_pass_target_matches_lead_point_without_error() -> void:
	# Precisión 1.0 ⇒ error 0 ⇒ el destino debe ser el punto adelantado exacto.
	var evaluator := SituationEvaluator.new()
	var result: Dictionary = evaluator.evaluate_pass_target(
		PLAYER_POSITION,
		PLAYER_VELOCITY,
		TEAMMATE_POSITION,
		Vector2(480.0, 450.0),
		FIELD_RECT,
		1.0,
		LEAD_DISTANCE,
		80.0,
		make_rng(),
	)

	var expected := PLAYER_POSITION + PLAYER_VELOCITY.normalized() * LEAD_DISTANCE
	check_approx(result.pass_target.x, expected.x, "destino sin error coincide en X con el punto adelantado")
	check_approx(result.pass_target.y, expected.y, "destino sin error coincide en Y con el punto adelantado")


func test_pass_target_stays_inside_safe_area_with_hostile_error() -> void:
	# Error máximo enorme: el destino sin clampar quedaría lejísimos; el
	# resultado debe respetar siempre el rectángulo seguro de la cancha.
	var evaluator := SituationEvaluator.new()
	var result: Dictionary = evaluator.evaluate_pass_target(
		PLAYER_POSITION,
		PLAYER_VELOCITY,
		TEAMMATE_POSITION,
		Vector2(700.0, 450.0),
		FIELD_RECT,
		0.0,
		LEAD_DISTANCE,
		100000.0,
		make_rng(),
	)

	check_point_in_rect(result.pass_target, SAFE_RECT, "destino con error extremo queda en la zona segura")


func test_quality_increases_when_rival_is_closer() -> void:
	# La calidad no depende del RNG: con todo lo demás igual, un rival encima
	# del jugador debe producir menor calidad que un rival lejísimos.
	var evaluator := SituationEvaluator.new()

	var rival_close: Dictionary = evaluator.evaluate_pass_target(
		PLAYER_POSITION,
		PLAYER_VELOCITY,
		TEAMMATE_POSITION,
		PLAYER_POSITION,
		FIELD_RECT,
		1.0,
		LEAD_DISTANCE,
		80.0,
		make_rng(),
	)
	var rival_far: Dictionary = evaluator.evaluate_pass_target(
		PLAYER_POSITION,
		PLAYER_VELOCITY,
		TEAMMATE_POSITION,
		PLAYER_POSITION + Vector2(500.0, 0.0),
		FIELD_RECT,
		1.0,
		LEAD_DISTANCE,
		80.0,
		make_rng(),
	)

	check(rival_far.quality > rival_close.quality, "calidad con rival lejano > calidad con rival encima")
	check(
		rival_close.quality >= 0.0 and rival_close.quality <= 1.0,
		"calidad con rival encima dentro de [0, 1] (obtenido %.4f)" % rival_close.quality
	)
	check(
		rival_far.quality >= 0.0 and rival_far.quality <= 1.0,
		"calidad con rival lejano dentro de [0, 1] (obtenido %.4f)" % rival_far.quality
	)
