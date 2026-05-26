extends FWDebugValueSelectPointBase
class_name FWDebugValueSelectPoint2D

func _init() -> void:
	_a_point_vec = Vector2.ZERO

func _update_value_text() -> void:
	super()
	if is_point_visible():
		_a_Value_Text.set_text("(%s, %s)" % [_a_point_vec.x, _a_point_vec.y])

func set_point_pos(p_pos: Vector2) -> void:
	_a_point.set_position(p_pos)

func set_point_scale(p_scale: Vector2) -> void:
	_a_point.set_scale(p_scale)
