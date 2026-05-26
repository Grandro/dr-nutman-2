extends FWCutsceneThreadBase
class_name FWCutsceneThreadSetMoveRoute

@export_enum("2D", "3D") var _e_dim: String = "2D"

var _a_object_key: StringName
var _a_state_key: StringName
var _a_speed: float
var _a_path_pos: Array
var _a_wait_finish: bool

func _ready() -> void:
	super()
	if !_a_loads_data:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		_a_object_key = cutscene_system_si.get_option_value(_a_args[&"Object"])
		_a_state_key = cutscene_system_si.get_option_value(_a_args[&"State"])
		_a_speed = cutscene_system_si.get_option_value(_a_args[&"Speed"])
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args[&"Wait_Finish"])
		var grid_step: Variant = _a_args[&"Grid"][&"Step"]
		var grid_start: Variant = _a_args[&"Grid"][&"Start"]
		var gen_points: Array = _a_args[&"Gen_Path"][&"Gen_Points"]
		for gen_point: Variant in gen_points:
			var pos: Variant = Global.grid_point_to_pos(gen_point, grid_step, grid_start)
			_a_path_pos.push_back(pos)
		
		_process_command()

func skip() -> void:
	super()
	var nav_agent_comp: Node = _a_object.comph().get_comp("Movement/Nav_Agent")
	nav_agent_comp.path_finished.disconnect(_on_Nav_Agent_path_finished)
	
	if !_a_path_pos.is_empty():
		var prev_pos: Variant
		if _a_path_pos.size() == 1:
			prev_pos = _a_object.get_global_position()
		else:
			prev_pos = _a_path_pos[-2]
		var new_pos: Variant = _a_path_pos[-1]
		var dir: StringName = Global.get_dir_to_pos(prev_pos, new_pos)
		var path: Array[Vector3] = []
		_a_object.set_global_position(new_pos)
		_a_object.comph().call_comp("Movement/Nav_Agent", &"set_path", [path])
		_a_object.comph().call_comp("States", &"set_state_tmp", [&"Stop"])
		_a_object.comph().call_comp("Movement", &"set_dir", [dir])
		_a_object.comph().call_comp("Anims", &"update_anim")
	
	queue_free()
	_emit_completed()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_object = global_si.get_object(_a_object_key)
	_a_object.comph().call_comp("Cutscene", &"increase_in_cutscene")
	
	var nav_agent_comp: Node = _a_object.comph().get_comp("Movement/Nav_Agent")
	nav_agent_comp.path_finished.connect(_on_Nav_Agent_path_finished)
	
	if !_a_path_pos.is_empty():
		_move_object_to_pos(_a_path_pos[0])
	if _a_path_pos.is_empty() && !_a_skip:
		queue_free()
	if (_a_path_pos.is_empty() || !_a_wait_finish) && !_a_skip && !_a_loads_data:
		_emit_completed()
	
	super()

func _move_object_to_pos(p_pos: Variant) -> void:
	var base_speed: float = Cutscene_System.get_movement_base_speed(_e_dim, _a_speed)
	var path: Array[Vector3]; path.assign([p_pos])
	_a_object.comph().call_comp("States", &"set_state_tmp", [_a_state_key])
	_a_object.comph().call_comp("Movement", &"set_base_speed", [base_speed])
	_a_object.comph().call_comp("Movement/Nav_Agent", &"set_path", [path])
	_a_object.comph().call_comp("Anims", &"update_anim")

func get_save_data() -> Dictionary:
	_add_revert_property(_a_object, _a_object_key, &"$Main", &"position")
	
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Object"] = {}
	args[&"Object"][&"Value"] = _a_object_key
	args[&"State_Key"] = _a_state_key
	args[&"Speed"] = _a_speed
	args[&"Path_Pos"] = _a_path_pos
	args[&"Wait_Finish"] = _a_wait_finish
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_object_key = args[&"Object"][&"Value"]
	_a_state_key = args[&"State_Key"]
	_a_speed = args[&"Speed"]
	_a_path_pos = args[&"Path_Pos"]
	_a_wait_finish = args[&"Wait_Finish"]
	
	_process_command()

func _on_Nav_Agent_path_finished() -> void:
	_a_path_pos.pop_front()
	
	if _a_path_pos.is_empty():
		_a_object.comph().call_comp("States", &"set_state_tmp", [&"Stop"])
		_a_object.comph().call_comp("Anims", &"update_anim")
		if !_a_skip:
			queue_free()
			if _a_wait_finish:
				_emit_completed()
	else:
		_move_object_to_pos(_a_path_pos[0])
