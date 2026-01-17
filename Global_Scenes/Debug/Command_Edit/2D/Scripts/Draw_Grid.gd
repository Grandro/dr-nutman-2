extends Node2D
class_name DebugCommandEditDrawGrid2D

var _a_start: Vector2
var _a_size: Vector2
var _a_step: Vector2

func update_grid() -> void:
	queue_redraw()

func set_start(p_start: Vector2) -> void:
	_a_start = p_start

func get_start() -> Vector2:
	return _a_start

func set_size(p_size: Vector2) -> void:
	_a_size = p_size

func set_step(p_step: Vector2) -> void:
	_a_step = p_step

func _draw():
	var world_width: float = _a_start.x + _a_size.x * _a_step.x
	var world_height: float = _a_start.y + _a_size.y * _a_step.y
	for x: int in _a_size.x + 1:
		var line_x: float = _a_start.x + x * _a_step.x
		var from: Vector2 = Vector2(line_x, _a_start.y)
		var to: Vector2 = Vector2(line_x, world_height)
		draw_line(from, to, Color.WHITE)
	
	for y: int in _a_size.y + 1:
		var line_y: float = _a_start.y + y * _a_step.y
		var from: Vector2 = Vector2(_a_start.x, line_y)
		var to: Vector2 = Vector2(world_width, line_y)
		draw_line(from, to, Color.WHITE)
