extends FWObjectCompBehaviorStatesStateBase
class_name FWObjectCompBehaviorStatesStateAnim

@export var _e_name: StringName = &""

func process_start() -> void:
	var anims_comp: FWCompAnims = _a_entity_comph.get_comp("Anims")
	if !_e_use_process_time:
		anims_comp.animation_finished.connect(_on_Anims_anim_finished)
	_a_entity_comph.call_comp("States", &"set_state", [_e_name])
	anims_comp.update_anim()
	
	super()

func process_end() -> void:
	if !_e_use_process_time:
		var anims_comp: FWCompAnims = _a_entity_comph.get_comp("Anims")
		anims_comp.animation_finished.disconnect(_on_Anims_anim_finished)
	
	super()

func _on_Anims_anim_finished(_p_name: StringName) -> void:
	processed.emit()
