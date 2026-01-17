extends DestinationDataBase
class_name DestinationData2D

@export var _e_pos: Vector2 = Vector2.ZERO
@export var _e_camera_limit: Dictionary[Side, int] = {SIDE_LEFT: -10000000,
													  SIDE_TOP: -10000000,
													  SIDE_RIGHT: 10000000,
													  SIDE_BOTTOM: 10000000}

func get_pos() -> Vector2:
	return _e_pos

func get_camera_limit() -> Dictionary[Side, int]:
	return _e_camera_limit
