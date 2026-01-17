extends DestinationDataBase
class_name DestinationData3D

@export var _e_pos: Vector3 = Vector3.ZERO
@export var _e_camera_limit: Dictionary[Side, float] = {SIDE_LEFT: -10000000.0,
														SIDE_TOP: -10000000.0,
														SIDE_RIGHT: 10000000.0,
														SIDE_BOTTOM: 10000000.0}

func get_pos() -> Vector3:
	return _e_pos

func get_camera_limit() -> Dictionary[Side, float]:
	return _e_camera_limit
