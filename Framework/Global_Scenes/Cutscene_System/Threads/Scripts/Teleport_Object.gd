extends FWCutsceneThreadBase
class_name FWCutsceneThreadTeleportObject

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var point_selected: bool = _a_args[&"Point"][&"Selected"]
	var point_type: StringName = _a_args[&"Point"][&"Type"]
	if point_selected || point_type == &"Var":
		var global_si: Global = Global.get_singleton(self, "Global")
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var object_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Object"])
		var point: Variant = cutscene_system_si.get_option_value(_a_args[&"Point"])
		_a_object = global_si.get_object(object_key)
		_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
		
		var grid_step: Variant = _a_args[&"Grid"][&"Step"]
		var grid_start: Variant = _a_args[&"Grid"][&"Start"]
		var pos: Variant = Global.grid_point_to_pos(point, grid_step, grid_start)
		_a_object.set_global_position(pos)
	
	queue_free()
	_emit_completed()
	
	super()
