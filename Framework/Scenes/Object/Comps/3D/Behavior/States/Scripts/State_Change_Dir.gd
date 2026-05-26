extends FWObjectCompBehaviorStatesStateBase
class_name FWObjectCompBehaviorStatesStateChangeDir

@export_enum("Rndm", "Look_At") var _e_type: String = "Rndm"

func process_start() -> void:
	var dir: StringName
	match _e_type:
		"Rndm": dir = _get_dir_rndm()
		"Look_At": dir = _get_dir_look_at()
	_a_entity_comph.call_comp("Movement", &"set_dir", [dir])
	_a_entity_comph.call_comp("Anims", &"update_anim")
	
	processed.emit()

func _get_dir_rndm() -> StringName:
	var curr_dir: StringName = _a_entity_comph.call_comp("Movement", &"get_dir")
	return Global.get_rndm_dir(curr_dir)

func _get_dir_look_at() -> StringName:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	return Global.get_dir_to_pos(entity_pos, target_pos)
