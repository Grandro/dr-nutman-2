extends FWObjectCompBehaviorStatesStateMoveBase
class_name FWObjectCompBehaviorStatesStateMoveRndm

func _get_point() -> Vector3:
	var entity_pos: Vector3 = _a_entity.get_global_position()
	return _get_point_circle(entity_pos, _e_min_radius, _e_max_radius)
