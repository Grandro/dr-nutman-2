extends CutsceneThreadBase
class_name CutsceneThreadChangeDialogueArgsIdx

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var object_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Object"])
	var type: StringName = cutscene_system_si.get_option_value(_a_args[&"Type"])
	var idx: int = cutscene_system_si.get_option_value(_a_args[&"Idx"])
	var args_idx: int = cutscene_system_si.get_option_value(_a_args[&"Value"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	
	var interactions_comp: Node = _a_object.comph().get_comp("Interactions")
	match type:
		&"Set": interactions_comp.set_interaction_dialogue_args_idx(idx, args_idx)
		&"Increase": interactions_comp.increase_interaction_dialogue_args_idx(idx, args_idx)
		&"Decrease": interactions_comp.decrease_interaction_dialogue_args_idx(idx, args_idx)
	
	_emit_completed()
	queue_free()
	
	super()
