extends CutsceneThreadBase
class_name CutsceneThreadSetAvoidance

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var object_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Object"])
	var avoidance: bool = cutscene_system_si.get_option_value(_a_args[&"Avoidance"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	_a_object.comph().call_comp("Movement/Nav_Agent", &"set_avoidance_enabled", [avoidance])
	
	_emit_completed()
	queue_free()
	
	super()
