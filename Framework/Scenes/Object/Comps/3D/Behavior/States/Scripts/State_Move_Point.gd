extends FWObjectCompBehaviorStatesStateMoveBase
class_name FWObjectCompBehaviorStatesStateMovePoint

@export var _e_point: Vector3

func _get_point() -> Vector3:
	return _get_point_circle(_e_point, _e_min_radius, _e_max_radius)
