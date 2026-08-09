extends FWObjectCompBehaviorStatesStateBase
class_name FWObjectCompBehaviorStatesStateChangeDir

@export_enum("Rndm", "Look_At") var _e_type: String = "Rndm"

func process_start() -> void:
	var dir_name: StringName
	match _e_type:
		"Rndm": dir_name = _get_dir_name_rndm()
		"Look_At": dir_name = _get_dir_name_look_at()
	_a_entity_comph.call_comp("Movement", &"set_dir_name", [dir_name])
	_a_entity_comph.call_comp("Anims", &"update_anim")
	
	if _e_use_process_time:
		_a_Process_Time.start(_e_process_time)
	else:
		processed.emit()

func _get_dir_name_rndm() -> StringName:
	var curr_dir_name: StringName = _a_entity_comph.call_comp("Movement", &"get_dir_name")
	return Global.get_rndm_dir_name(curr_dir_name)

func _get_dir_name_look_at() -> StringName:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	return Global.get_dir_name_to_pos(entity_pos, target_pos)
