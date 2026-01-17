extends CompAnims
class_name CompSVAnims

func update_anim() -> void:
	if !_a_entity_comph.has_comp("States"):
		return
	if !_a_entity_comph.has_comp("Movement"):
		return
	
	var state_tmp: StringName = _a_entity_comph.call_comp("States", &"get_state_tmp")
	var dir: StringName = _a_entity_comph.call_comp("Movement", &"get_dir")
	var anim_name: StringName = "SV/%s_%s" % [state_tmp, dir]
	play_anim(anim_name)
