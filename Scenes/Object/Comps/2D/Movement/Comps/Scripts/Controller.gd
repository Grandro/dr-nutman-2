extends CompMovementControllerBase
class_name CompMovementController2D

func _init() -> void:
	_a_velocity = Vector2.ZERO

func _get_input_velocity() -> Vector2:
	return Input.get_vector(&"Move_Left", &"Move_Right", &"Move_Up", &"Move_Down")

func _is_on_floor() -> bool:
	return true
