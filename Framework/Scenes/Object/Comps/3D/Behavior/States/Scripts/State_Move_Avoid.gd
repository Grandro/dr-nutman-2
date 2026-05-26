extends FWObjectCompBehaviorStatesStateMoveBase
class_name FWObjectCompBehaviorStatesStateMoveAvoid

func _get_point() -> Vector3:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	var away_vec: Vector3 = entity_pos - target_pos
	return _get_point_rotated(entity_pos, away_vec, _e_min_radius, _e_max_radius)
