class_name TargetArrow
extends Node2D


const COLOR_NEUTRAL: Color = Color(0.6, 0.6, 0.6, 0.95)
const COLOR_VALID: Color = Color(0.35, 0.85, 0.45, 0.95)

@onready var _line: Line2D = $Line
@onready var _head: Polygon2D = $Head


func _ready() -> void:
	hide()
	_apply_color(COLOR_NEUTRAL)


func show_arrow(start: Vector2, end: Vector2) -> void:
	show()
	update_endpoints(start, end)


func hide_arrow() -> void:
	hide()


func update_endpoints(start: Vector2, end: Vector2) -> void:
	_line.points = PackedVector2Array([start, end])
	_head.position = end
	_head.rotation = (end - start).angle() + PI / 2.0


func set_valid_target(is_valid: bool) -> void:
	_apply_color(COLOR_VALID if is_valid else COLOR_NEUTRAL)


func _apply_color(color: Color) -> void:
	_line.default_color = color
	_head.color = color
