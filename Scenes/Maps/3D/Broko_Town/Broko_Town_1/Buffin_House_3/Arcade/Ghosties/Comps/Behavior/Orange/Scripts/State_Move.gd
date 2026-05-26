extends FWObjectCompBehaviorStatesStateMoveBase
class_name ArcadeGhostyOrangeCompBehaviorStateMove

@export var _e_rndm_min_radius: float = 2.0
@export var _e_rndm_max_radius: float = 5.0

var _a_ghosty_pink: ArcadeGhostyBase

func _get_point() -> Vector3:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	var ghosty_pink_pos: Vector3 = _a_ghosty_pink.get_global_position()
	var rndm_pos: Vector3 = _get_point_circle(entity_pos, _e_rndm_min_radius, _e_rndm_max_radius)
	var to_pos: Vector3 = target_pos + (ghosty_pink_pos - target_pos) / 2.0 + (entity_pos - rndm_pos)
	var to_vec: Vector3 = to_pos - entity_pos
	return _get_point_rotated(entity_pos, to_vec, _e_min_radius, _e_max_radius)

func set_ghosty_pink(p_ghosty_pink: ArcadeGhostyBase) -> void:
	_a_ghosty_pink = p_ghosty_pink
