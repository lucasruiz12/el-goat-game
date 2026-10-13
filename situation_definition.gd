class_name SituationDefinition
extends Resource

## SituationDefinition reúne los parámetros de una situación del laboratorio.
## Main ejecuta siempre la misma escena, así que este recurso es el contrato
## que describe cómo se comporta cada situación concreta: tiempos, pase, rival
## y posiciones iniciales. El selector solo conoce id y título; Main solo
## conoce los parámetros, de modo que ninguna de las dos partes depende de la
## otra.
##
## Los valores se construyen todavía en código desde SituationCatalog y no en
## archivos .tres: con una sola situación, un recurso por archivo agregaría
## complejidad sin aportar. Conviene moverlos a .tres cuando el laboratorio
## tenga varias situaciones editables desde el inspector.

@export var id: StringName = &""
@export var title := ""

@export_category("Off-ball timing")
@export var off_ball_duration := 2.0
@export var restart_interval := 1.0

@export_category("Pass")
@export var ball_speed := 350.0
@export_range(0.0, 1.0, 0.05) var teammate_pass_precision := 0.72
@export var pass_lead_distance := 72.0
@export var maximum_pass_error := 80.0
@export var ball_contact_distance := 25.0
@export var ball_outside_grace_duration := 0.5

@export_category("Teammate")
@export var holder_shift_distance := 0.0
@export var holder_shift_speed := 60.0

@export_category("Rival")
@export var rival_count := 1
@export var rival_speed := 115.0
@export var minimum_initial_rival_distance := 150.0

@export_category("Starting regions")
@export var player_start_region := Rect2(0.35, 0.75, 0.30, 0.16)
@export var teammate_start_region := Rect2(0.33, 0.55, 0.34, 0.17)
@export var rival_start_region := Rect2(0.30, 0.18, 0.40, 0.28)
