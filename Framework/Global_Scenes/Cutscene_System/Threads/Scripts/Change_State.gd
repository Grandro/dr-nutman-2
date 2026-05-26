extends FWCutsceneThreadBase
class_name FWCutsceneThreadChangeState

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var object_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Object"])
	var state: StringName = cutscene_system_si.get_option_value(_a_args[&"State"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	_a_object.comph().call_comp("States", &"set_state", [state])
	_a_object.comph().call_comp("Anims", &"update_anim")
	
	queue_free()
	_emit_completed()
	
	super()
