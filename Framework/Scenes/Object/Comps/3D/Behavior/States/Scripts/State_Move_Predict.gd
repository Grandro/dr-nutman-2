extends FWObjectCompBehaviorStatesStateMoveBase
class_name FWObjectCompBehaviorStatesStateMovePredict

@export var _e_range: float = 5.0

func _get_point() -> Vector3:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	var target_velocity: Vector3 = target.comph().call_comp("Movement", &"get_velocity")
	var to_vec: Vector3 = (target_pos - entity_pos) + target_velocity.normalized() * _e_range
	return _get_point_rotated(entity_pos, to_vec, _e_min_radius, _e_max_radius)
