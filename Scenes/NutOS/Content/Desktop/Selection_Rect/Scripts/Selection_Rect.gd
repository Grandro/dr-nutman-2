extends Control
class_name NutOSContentDesktopSelectionRect

signal rect_updated(p_rect: Rect2)

@export var _e_color_inside: Color = Color(0.0, 0.53, 1.00, 0.15)
@export var _e_color_outside: Color = Color(0.0, 0.42, 0.8)

var _a_dragging: bool = false
var _a_from: Vector2i
var _a_rect: Rect2

func _process(_p_delta: float) -> void:
	queue_redraw()

func _gui_input(p_event: InputEvent) -> void:
	if !p_event.is_action(&"Mouse_Left"):
		return
	
	if p_event.is_released():
		_a_dragging = false
		queue_redraw()
	
	elif p_event.is_pressed():
		if !_a_dragging:
			_a_from = p_event.get_position()
			_a_dragging = true

func _draw() -> void:
	if !_a_dragging:
		return
	
	_a_rect.position = Vector2(_a_from)
	_a_rect.end = get_local_mouse_position()
	_a_rect = _a_rect.abs()
	draw_rect(_a_rect, _e_color_inside)
	draw_rect(_a_rect, _e_color_outside, false, 1.0)
	
	rect_updated.emit(_a_rect)
