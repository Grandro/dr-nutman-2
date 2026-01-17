extends CompMovementControllerBase
class_name CompMovementController3D

func _init() -> void:
	_a_velocity = Vector3.ZERO

func _get_input_velocity() -> Vector3:
	var input_vec: Vector2 = Input.get_vector(&"Move_Left", &"Move_Right", &"Move_Up", &"Move_Down")
	var velocity = Vector3(input_vec.x, 0.0, input_vec.y)
	
	return velocity

func _is_on_floor() -> bool:
	return _a_entity.is_on_floor()
