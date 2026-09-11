extends Node2D

## Este nodo coordina el prototipo de oportunidades sin pelota: ubica el objetivo,
## detecta cuando el jugador lo alcanza y prepara la siguiente oportunidad. La grilla
## es un calculo logico sobre el viewport actual, por eso no requiere crear una cancha.
## Usar distancia entre posiciones es suficiente en este prototipo y evita introducir
## colisiones hasta que hagan falta para una regla de gameplay mas compleja.

const GRID_COLUMNS := 4
const GRID_ROWS := 3
const VALID_ZONE_INDICES := [1, 2, 5, 6]
const OPPORTUNITY_RADIUS := 24.0
const PLAYER_RADIUS := 16.0
const ZONE_MARGIN := 32.0
const FEEDBACK_DURATION := 0.25
const OPPORTUNITY_COLOR := Color(1.0, 0.76, 0.12)
const REACHED_COLOR := Color(0.3, 1.0, 0.5)

@onready var player: CharacterBody2D = $Player
@onready var opportunity: Polygon2D = $Opportunity

var random_number_generator := RandomNumberGenerator.new()
var is_resolving_opportunity := false
var current_zone_index := -1


func _ready() -> void:
	random_number_generator.randomize()
	place_next_opportunity()


func _process(_delta: float) -> void:
	if is_resolving_opportunity:
		return

	if player.global_position.distance_to(opportunity.global_position) <= PLAYER_RADIUS + OPPORTUNITY_RADIUS:
		resolve_opportunity()


func resolve_opportunity() -> void:
	is_resolving_opportunity = true
	opportunity.color = REACHED_COLOR
	await get_tree().create_timer(FEEDBACK_DURATION).timeout
	place_next_opportunity()
	is_resolving_opportunity = false


func place_next_opportunity() -> void:
	var visible_rect := get_viewport_rect()
	var cell_size := visible_rect.size / Vector2(GRID_COLUMNS, GRID_ROWS)
	var zone_index: int = VALID_ZONE_INDICES[random_number_generator.randi_range(0, VALID_ZONE_INDICES.size() - 1)]
	while zone_index == current_zone_index:
		zone_index = VALID_ZONE_INDICES[random_number_generator.randi_range(0, VALID_ZONE_INDICES.size() - 1)]
	var column := zone_index % GRID_COLUMNS
	var row := zone_index / GRID_COLUMNS
	var zone_rect := Rect2(visible_rect.position + Vector2(column, row) * cell_size, cell_size)
	var horizontal_margin := minf(ZONE_MARGIN, cell_size.x * 0.5 - OPPORTUNITY_RADIUS)
	var vertical_margin := minf(ZONE_MARGIN, cell_size.y * 0.5 - OPPORTUNITY_RADIUS)

	opportunity.global_position = Vector2(
		random_number_generator.randf_range(zone_rect.position.x + OPPORTUNITY_RADIUS + horizontal_margin, zone_rect.end.x - OPPORTUNITY_RADIUS - horizontal_margin),
		random_number_generator.randf_range(zone_rect.position.y + OPPORTUNITY_RADIUS + vertical_margin, zone_rect.end.y - OPPORTUNITY_RADIUS - vertical_margin)
	)
	opportunity.color = OPPORTUNITY_COLOR
	current_zone_index = zone_index
