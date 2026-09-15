class_name Field
extends Node2D

## Field representa la mitad ofensiva de la cancha y concentra su sistema de
## coordenadas. Las referencias se calculan desde este origen local: el arco rival
## esta arriba (y = 0) y la linea de mitad de cancha esta abajo. Asi, los sistemas
## futuros pueden consultar posiciones futbolisticas sin depender de la escena Main.
## Las propiedades exportadas se pueden ajustar desde el inspector sin reescribir la
## geometria que usan las oportunidades o futuros evaluadores de desmarque.

@export_category("Dimensions")
@export var field_size := Vector2(960.0, 540.0)
@export var goal_width := 120.0
@export var goal_depth := 18.0
@export var penalty_area_width := 320.0
@export var penalty_area_depth := 120.0
@export var goal_area_width := 160.0
@export var goal_area_depth := 55.0
@export var center_circle_radius := 80.0
@export var penalty_arc_radius := 52.0
@export var penalty_spot_distance := 85.0
@export var penalty_arc_distance := 120.0

@export_category("Visuals")
@export var surface_color := Color(0.08, 0.35, 0.18)
@export var line_color := Color(0.9, 0.95, 0.9)

@onready var surface: Polygon2D = $Surface
@onready var boundary: Line2D = $Boundary
@onready var midfield_line: Line2D = $MidfieldLine
@onready var center_circle: Line2D = $CenterCircle
@onready var center_spot: Polygon2D = $CenterSpot
@onready var penalty_area: Line2D = $PenaltyArea
@onready var goal_area: Line2D = $GoalArea
@onready var penalty_arc: Line2D = $PenaltyArc
@onready var penalty_spot: Polygon2D = $PenaltySpot
@onready var rival_goal: Line2D = $RivalGoal


func _ready() -> void:
	configure_visuals()


func get_field_rect() -> Rect2:
	return Rect2(global_position, field_size)


func get_midfield_line_y() -> float:
	return global_position.y + field_size.y



func get_rival_goal_center() -> Vector2:
	return global_position + Vector2(field_size.x * 0.5, 0.0)


func get_penalty_spot_position() -> Vector2:
	return global_position + Vector2(field_size.x * 0.5, penalty_spot_distance)


func get_rival_penalty_area() -> Rect2:
	var local_position := Vector2((field_size.x - penalty_area_width) * 0.5, 0.0)
	return Rect2(global_position + local_position, Vector2(penalty_area_width, penalty_area_depth))


func get_left_touchline_x() -> float:
	return global_position.x


func get_right_touchline_x() -> float:
	return global_position.x + field_size.x


func get_grid_cell_rect(columns: int, rows: int, column: int, row: int) -> Rect2:
	var cell_size := field_size / Vector2(columns, rows)
	return Rect2(global_position + Vector2(column, row) * cell_size, cell_size)


func configure_visuals() -> void:
	var penalty_left_x := (field_size.x - penalty_area_width) * 0.5
	var penalty_right_x := penalty_left_x + penalty_area_width
	var goal_area_left_x := (field_size.x - goal_area_width) * 0.5
	var goal_area_right_x := goal_area_left_x + goal_area_width
	var goal_left_x := (field_size.x - goal_width) * 0.5
	var goal_right_x := goal_left_x + goal_width

	surface.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(field_size.x, 0.0),
		field_size,
		Vector2(0.0, field_size.y),
	])
	surface.color = surface_color
	configure_line(boundary, PackedVector2Array([
		Vector2.ZERO,
		Vector2(field_size.x, 0.0),
		field_size,
		Vector2(0.0, field_size.y),
		Vector2.ZERO,
	]), line_color, 4.0)
	configure_line(midfield_line, PackedVector2Array([
		Vector2(0.0, field_size.y),
		field_size,
	]), line_color, 3.0)
	configure_line(center_circle, build_arc_points(
		Vector2(field_size.x * 0.5, field_size.y),
		center_circle_radius,
		PI,
		TAU,
	), line_color, 3.0)
	center_spot.position = Vector2(field_size.x * 0.5, field_size.y)
	center_spot.polygon = PackedVector2Array([
		Vector2(-4.0, -4.0),
		Vector2(4.0, -4.0),
		Vector2(4.0, 4.0),
		Vector2(-4.0, 4.0),
	])
	center_spot.color = line_color
	configure_line(penalty_area, PackedVector2Array([
		Vector2(penalty_left_x, 0.0),
		Vector2(penalty_left_x, penalty_area_depth),
		Vector2(penalty_right_x, penalty_area_depth),
		Vector2(penalty_right_x, 0.0),
	]), line_color, 3.0)
	configure_line(goal_area, PackedVector2Array([
		Vector2(goal_area_left_x, 0.0),
		Vector2(goal_area_left_x, goal_area_depth),
		Vector2(goal_area_right_x, goal_area_depth),
		Vector2(goal_area_right_x, 0.0),
	]), line_color, 3.0)
	configure_line(penalty_arc, build_arc_points(
		Vector2(field_size.x * 0.5, penalty_arc_distance),
		penalty_arc_radius,
		0.0,
		PI,
	), line_color, 3.0)
	penalty_spot.position = Vector2(field_size.x * 0.5, penalty_spot_distance)
	penalty_spot.polygon = PackedVector2Array([
		Vector2(-4.0, -4.0),
		Vector2(4.0, -4.0),
		Vector2(4.0, 4.0),
		Vector2(-4.0, 4.0),
	])
	penalty_spot.color = line_color
	configure_line(rival_goal, PackedVector2Array([
		Vector2(goal_left_x, 0.0),
		Vector2(goal_left_x, -goal_depth),
		Vector2(goal_right_x, -goal_depth),
		Vector2(goal_right_x, 0.0),
	]), line_color, 3.0)


func configure_line(line: Line2D, points: PackedVector2Array, color: Color, width: float) -> void:
	line.points = points
	line.default_color = color
	line.width = width


func build_arc_points(center: Vector2, radius: float, start_angle: float, end_angle: float, segments := 16) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments + 1):
		var progress := float(index) / segments
		var angle := lerpf(start_angle, end_angle, progress)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points
