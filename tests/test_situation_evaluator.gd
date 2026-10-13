extends "res://tests/test_case.gd"

## Pruebas de SituationEvaluator: matemática del pase con RNG sembrado para
## ser deterministas. Protegen (1) que sin error el destino es exactamente el
## punto adelantado, (2) que un error enorme nunca saca el destino de la zona
## segura de la cancha, (3) que la calidad separa peor/mejor según la
## distancia del rival, permaneciendo en [0, 1], y (4) la línea de pase contra
## colecciones de rivales: línea libre, rival cerca del segmento, del origen y
## del destino, varios rivales y colección vacía.

const FIELD_RECT := Rect2(0.0, 0.0, 960.0, 540.0)
const SAFE_RECT := Rect2(24.0, 24.0, 912.0, 492.0)  # FIELD_RECT.grow(-24.0)
const SEEDED_SEED := 12345

const PLAYER_POSITION := Vector2(480.0, 300.0)
const PLAYER_VELOCITY := Vector2(1.0, 0.0)
const TEAMMATE_POSITION := Vector2(600.0, 200.0)
const LEAD_DISTANCE := 72.0
const LANE_ORIGIN := Vector2(0.0, 0.0)
const LANE_TARGET := Vector2(200.0, 0.0)


func run() -> void:
	test_pass_target_matches_lead_point_without_error()
	test_pass_target_stays_inside_safe_area_with_hostile_error()
	test_quality_increases_when_rival_is_closer()
	test_pass_lane_is_freed_without_nearby_rivals()
	test_pass_lane_detects_rival_close_to_the_line()
	test_pass_lane_detects_rival_close_to_the_origin()
	test_pass_lane_detects_rival_close_to_the_destination()
	test_pass_lane_considers_every_rival()
	test_pass_lane_is_freed_without_rivals()


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


func test_pass_lane_is_freed_without_nearby_rivals() -> void:
	# Un rival lejano deja la línea totalmente clara (tope de la escala).
	var evaluator := SituationEvaluator.new()
	var distant_rivals: Array[Vector2] = [Vector2(0.0, 300.0)]
	var result: Dictionary = evaluator.evaluate_pass_lane(LANE_ORIGIN, LANE_TARGET, distant_rivals)

	check_approx(result.lane_quality, 1.0, "línea con rival lejano = totalmente clara")
	check_approx(result.closest_rival_distance, 300.0, "la distancia al rival lejano es la perpendicular al segmento")


func test_pass_lane_detects_rival_close_to_the_line() -> void:
	# Un rival a mitad de segmento, sobre la perpendicular: la calidad baja
	# según su distancia al segmento completo.
	var evaluator := SituationEvaluator.new()
	var line_rivals: Array[Vector2] = [Vector2(100.0, 30.0)]
	var result: Dictionary = evaluator.evaluate_pass_lane(LANE_ORIGIN, LANE_TARGET, line_rivals)

	check_approx(result.closest_rival_distance, 30.0, "la distancia mide qué tan cerca pasa el rival del segmento")
	check_approx(
		result.lane_quality,
		30.0 / SituationEvaluator.LANE_CLEARNESS_SCALE,
		"la calidad de la línea sigue la escala de claridad",
	)


func test_pass_lane_detects_rival_close_to_the_origin() -> void:
	# Un rival sobre el origen del pase: distancia 0 y línea bloqueada.
	var evaluator := SituationEvaluator.new()
	var origin_rivals: Array[Vector2] = [LANE_ORIGIN]
	var result: Dictionary = evaluator.evaluate_pass_lane(LANE_ORIGIN, LANE_TARGET, origin_rivals)

	check_approx(result.closest_rival_distance, 0.0, "el rival sobre el origen está a distancia 0 del segmento")
	check_approx(result.lane_quality, 0.0, "la línea con un rival sobre el origen queda bloqueada")


func test_pass_lane_detects_rival_close_to_the_destination() -> void:
	# El cierre del segmento también cuenta: un rival bajo el destino restringe
	# la línea igual que uno a mitad de camino.
	var evaluator := SituationEvaluator.new()
	var destination_rivals: Array[Vector2] = [LANE_TARGET + Vector2(0.0, 12.0)]
	var result: Dictionary = evaluator.evaluate_pass_lane(LANE_ORIGIN, LANE_TARGET, destination_rivals)

	check_approx(result.closest_rival_distance, 12.0, "la distancia mide al rival junto al destino")
	check_approx(
		result.lane_quality,
		12.0 / SituationEvaluator.LANE_CLEARNESS_SCALE,
		"la calidad refleja al rival que cierra el destino",
	)


func test_pass_lane_considers_every_rival() -> void:
	# Con varios rivales gobierna el más cercano al segmento, no el último ni
	# el primero: los rivales lejanos no enmascaran al que está a 50 px.
	var evaluator := SituationEvaluator.new()
	var mixed_rivals: Array[Vector2] = [
		Vector2(0.0, 300.0),
		Vector2(100.0, 50.0),
		Vector2(500.0, 500.0),
	]
	var result: Dictionary = evaluator.evaluate_pass_lane(LANE_ORIGIN, LANE_TARGET, mixed_rivals)

	check_approx(result.closest_rival_distance, 50.0, "de todos los rivales se queda la distancia mínima al segmento")
	check_approx(
		result.lane_quality,
		50.0 / SituationEvaluator.LANE_CLEARNESS_SCALE,
		"la calidad responde al rival más cercano de la colección",
	)


func test_pass_lane_is_freed_without_rivals() -> void:
	# Colección vacía: no hay amenaza y la línea es totalmente clara.
	var evaluator := SituationEvaluator.new()
	var no_rivals: Array[Vector2] = []
	var result: Dictionary = evaluator.evaluate_pass_lane(LANE_ORIGIN, LANE_TARGET, no_rivals)

	check_approx(result.lane_quality, 1.0, "sin rivales la línea es totalmente clara")
	check(is_inf(result.closest_rival_distance), "sin rivales la distancia más cercana es infinita")
