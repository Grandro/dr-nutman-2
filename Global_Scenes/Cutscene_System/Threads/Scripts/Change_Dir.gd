extends CutsceneThreadBase
class_name CutsceneThreadChangeDir

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var args: Dictionary = _a_args[&"Args"]
	var object_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Object"])
	var type: StringName = cutscene_system_si.get_option_value(_a_args[&"Type"])
	_a_object = global_si.get_object(object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	
	var dir: StringName = _a_object.comph().call_comp("Movement", &"get_dir")
	match type:
		&"Fixed_Dir":
			dir = cutscene_system_si.get_option_value(args[&"Dir"])
		
		&"Look_Degrees":
			var degrees: float = cutscene_system_si.get_option_value(args[&"Degrees"])
			dir = global_si.get_dir_rotated(dir, degrees)
		
		_:  # Look_At, Look_Away
			var start: Variant = _a_object.get_global_position()
			var look_type: StringName = cutscene_system_si.get_option_value(args[&"Type"])
			match look_type:
				&"Object":
					var look_object_key: StringName = cutscene_system_si.get_option_value(args[&"Object"])
					var look_object: Node = global_si.get_object(look_object_key)
					var end: Variant = look_object.get_global_position()
					if type == &"Look_At":
						dir = global_si.get_dir_to_pos(start, end)
					elif type == &"Look_Away":
						dir = global_si.get_opposite_dir(dir)
				
				&"Point":
					var selected: bool = args[&"Point"][&"Selected"]
					if selected:
						var point: Variant = cutscene_system_si.get_option_value(args[&"Point"])
						var grid_step: Variant = _a_args[&"Grid"][&"Step"]
						var grid_start: Variant = _a_args[&"Grid"][&"Start"]
						var end: Variant = grid_start + (point * grid_step) + (grid_step / 2)
						if type == &"Look_At":
							dir = global_si.get_dir_to_pos(start, end)
						elif type == &"Look_Away":
							dir = global_si.get_opposite_dir(dir)
	
	_a_object.comph().call_comp("Movement", &"set_dir", [dir])
	_a_object.comph().call_comp("Anims", &"update_anim")
	
	_emit_completed()
	queue_free()
	
	super()
