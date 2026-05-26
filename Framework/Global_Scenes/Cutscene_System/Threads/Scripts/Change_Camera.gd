extends FWCutsceneThreadBase
class_name FWCutsceneThreadChangeCamera

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var object_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Object"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	var camera: Node = _a_object.comph().get_comp("Camera")
	global_si.set_curr_camera(camera)
	
	queue_free()
	_emit_completed()
	
	super()
