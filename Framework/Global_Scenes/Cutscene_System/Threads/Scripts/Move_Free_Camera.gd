extends FWCutsceneThreadBase
class_name FWCutsceneThreadMoveFreeCamera

@export_enum("2D", "3D") var _e_dim: String = "2D"

var _a_type: StringName
var _a_interpolate: bool
var _a_elapsed_time: float
var _a_duration_factor: float
var _a_trans_type: Tween.TransitionType
var _a_ease_type: Tween.EaseType
var _a_wait_finish: bool
var _a_start_object_key: StringName
var _a_end_object_key: StringName
var _a_change_camera: bool
var _a_point_selected: bool
var _a_pos: Array = []

var _a_tween: Tween = null
var _a_end_object: Node

func _ready() -> void:
	super()
	if !_a_loads_data:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var speed: float = cutscene_system_si.get_option_value(_a_args[&"Speed"])
		var trans_type: StringName = cutscene_system_si.get_option_value(_a_args[&"Trans_Type"])
		var ease_type: StringName = cutscene_system_si.get_option_value(_a_args[&"Ease_Type"])
		_a_type = cutscene_system_si.get_option_value(_a_args[&"Type"])
		_a_interpolate = cutscene_system_si.get_option_value(_a_args[&"Interpolate"])
		_a_duration_factor = Cutscene_System.get_movement_duration_factor(_e_dim, speed)
		_a_trans_type = Global.convert_trans_type_key(trans_type)
		_a_ease_type = Global.convert_ease_type_key(ease_type)
		_a_wait_finish = cutscene_system_si.get_option_value(_a_args[&"Wait_Finish"])
		match _a_type:
			&"Move_Route": _prep_ready_move_route()
			&"Object_To_Object": _prep_ready_object_to_object(cutscene_system_si)
			&"Object_To_Point": _prep_ready_object_to_point(cutscene_system_si)
		
		_process_command()

func _prep_ready_move_route() -> void:
	var grid_step: Variant = _a_args[&"Grid"][&"Step"]
	var grid_start: Variant = _a_args[&"Grid"][&"Start"]
	var gen_points: Array = _a_args[&"Gen_Path"][&"Gen_Points"]
	if _a_interpolate:
		for point: Variant in gen_points:
			var pos: Variant = Global.grid_point_to_pos(point, grid_step, grid_start)
			_a_pos.push_back(pos)
	else:
		var last_point: Variant = gen_points[-1]
		var pos: Variant = Global.grid_point_to_pos(last_point, grid_step, grid_start)
		_a_pos = [pos]

func _prep_ready_object_to_object(p_cutscene_system_si: Cutscene_System) -> void:
	_a_start_object_key = p_cutscene_system_si.get_option_value(_a_args[&"Start_Object"])
	_a_end_object_key = p_cutscene_system_si.get_option_value(_a_args[&"End_Object"])
	_a_change_camera = p_cutscene_system_si.get_option_value(_a_args[&"Change_Camera"])

func _prep_ready_object_to_point(p_cutscene_system_si: Cutscene_System) -> void:
	var point: Variant = p_cutscene_system_si.get_option_value(_a_args[&"Point"])
	var grid_step: Variant = _a_args[&"Grid"][&"Step"]
	var grid_start: Variant = _a_args[&"Grid"][&"Start"]
	var pos: Variant = Global.grid_point_to_pos(point, grid_step, grid_start)
	_a_start_object_key = p_cutscene_system_si.get_option_value(_a_args[&"Start_Object"])
	_a_point_selected = _a_args[&"Point"][&"Selected"]
	_a_pos = [pos]

func skip() -> void:
	super()
	if _a_tween != null:
		_a_tween.kill()
	
	match _a_type:
		&"Move_Route": _skip_move_route()
		&"Object_To_Object": _skip_object_to_object()
		&"Object_To_Point": _skip_object_to_point()
	
	queue_free()
	_emit_completed()

func _skip_move_route() -> void:
	if !_a_pos.is_empty():
		var global_si: Global = Global.get_singleton(self, "Global")
		var free_camera: Node = _a_curr_scene.get_free_camera()
		var camera_comp: Node = free_camera.comph().get_comp("Camera")
		var pos: Variant = _a_pos[-1]
		free_camera.set_global_position(pos)
		global_si.set_curr_camera(camera_comp)

func _skip_object_to_object() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var free_camera: Node = _a_curr_scene.get_free_camera()
	var end_pos: Variant = _a_end_object.get_global_position()
	free_camera.set_global_position(end_pos)

	var camera_comp: Node
	if _a_change_camera:
		camera_comp = _a_end_object.comph().get_comp("Camera")
	else:
		camera_comp = free_camera.comph().get_comp("Camera")
	global_si.set_curr_camera(camera_comp)

func _skip_object_to_point() -> void:
	if _a_point_selected:
		var global_si: Global = Global.get_singleton(self, "Global")
		var free_camera: Node = _a_curr_scene.get_free_camera()
		var camera_comp: Node = free_camera.comph().get_comp("Camera")
		var pos: Variant = _a_pos[-1]
		free_camera.set_global_position(pos)
		global_si.set_curr_camera(camera_comp)

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var free_camera: Node = _a_curr_scene.get_free_camera()
	match _a_type:
		&"Move_Route": _process_command_move_route(global_si, free_camera)
		&"Object_To_Object": _process_command_object_to_object(global_si, free_camera)
		&"Object_To_Point": _process_command_object_to_point(global_si, free_camera)
	
	super()

func _process_command_move_route(p_global_si: Global, p_free_camera: Node) -> void:
	if _a_interpolate:
		if !_a_pos.is_empty():
			_move_free_camera_to_pos(_a_pos[0])
		if _a_pos.is_empty() && !_a_skip:
			queue_free()
		if (_a_pos.is_empty() || !_a_wait_finish) && !_a_skip && !_a_loads_data:
			_emit_completed()
	else:
		if !_a_pos.is_empty():
			var pos: Variant = _a_pos[0]
			var camera_comp: Node = p_free_camera.comph().get_comp("Camera")
			p_free_camera.set_global_position(pos)
			p_global_si.set_curr_camera(camera_comp)
		
		if !_a_skip:
			queue_free()
			if !_a_loads_data:
				_emit_completed()

func _process_command_object_to_object(p_global_si: Global, p_free_camera: Node) -> void:
	_a_end_object = p_global_si.get_object(_a_end_object_key)
	if _a_interpolate:
		var start_object: Node = p_global_si.get_object(_a_start_object_key)
		var start_pos: Variant = start_object.get_global_position()
		p_free_camera.set_global_position(start_pos)
		
		_move_free_camera_to_object(_a_end_object)
		_a_tween.custom_step(_a_elapsed_time)
		if !_a_wait_finish && !_a_skip && !_a_loads_data:
			_emit_completed()
	else:
		var end_pos: Variant = _a_end_object.get_global_position()
		var camera_comp: Node = p_free_camera.comph().get_comp("Camera")
		p_free_camera.set_global_position(end_pos)
		p_global_si.set_curr_camera(camera_comp)
		if !_a_skip:
			queue_free()
			_emit_completed()

func _process_command_object_to_point(p_global_si: Global, p_free_camera: Node) -> void:
	if _a_interpolate:
		var start_object: Node = p_global_si.get_object(_a_start_object_key)
		var start_pos: Variant = start_object.get_global_position()
		p_free_camera.set_global_position(start_pos)
		
		if _a_point_selected:
			_move_free_camera_to_pos(_a_pos[0])
			_a_tween.custom_step(_a_elapsed_time)
			if !_a_wait_finish && !_a_skip && !_a_loads_data:
				_emit_completed()
		else:
			if !_a_skip:
				queue_free()
				_emit_completed()
	else:
		if _a_point_selected:
			var camera_comp: Node = p_free_camera.comph().get_comp("Camera")
			p_free_camera.set_global_position(_a_pos[0])
			p_global_si.change_curr_camera(camera_comp)
		
		if !_a_skip:
			queue_free()
			_emit_completed()

func _move_free_camera_to_pos(p_pos: Variant) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var free_camera: Node = _a_curr_scene.get_free_camera()
	var camera_comp: Node = free_camera.comph().get_comp("Camera")
	global_si.set_curr_camera(camera_comp)
	
	var start_pos: Variant = free_camera.get_global_position()
	var end_pos: Variant = p_pos
	var distance: float = start_pos.distance_to(end_pos)
	var duration: float = distance / _a_duration_factor
	
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Tween_finished)
	_a_tween.set_trans(_a_trans_type)
	_a_tween.set_ease(_a_ease_type)
	var tween_property: PropertyTweener = _a_tween.tween_property(free_camera, "global_position", end_pos, duration)
	tween_property.from(start_pos)

func _move_free_camera_to_object(p_object: Node) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var free_camera: Node = _a_curr_scene.get_free_camera()
	var camera_comp: Node = free_camera.comph().get_comp("Camera")
	global_si.set_curr_camera(camera_comp)
	
	var from_pos: Variant = free_camera.get_global_position()
	var to_pos: Variant = p_object.get_global_position()
	var distance: float = from_pos.distance_to(to_pos)
	var duration: float = distance / _a_duration_factor
	
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Tween_finished)
	_a_tween.set_trans(_a_trans_type)
	_a_tween.set_ease(_a_ease_type)
	var method: Callable = func(t): free_camera.set_global_position(from_pos.lerp(p_object.get_global_position(), t))
	_a_tween.tween_method(method, 0.0, 1.0, duration)

func _tween_finished_move_route() -> void:
	_a_pos.pop_front()
	if _a_pos.is_empty():
		if !_a_skip:
			queue_free()
		if _a_wait_finish && !_a_skip:
			_emit_completed()
	else:
		_move_free_camera_to_pos(_a_pos[0])

func _tween_finished_object_to_object() -> void:
	if _a_change_camera:
		var global_si: Global = Global.get_singleton(self, "Global")
		var end_object_camera: Node = _a_end_object.comph().get_comp("Camera")
		global_si.set_curr_camera(end_object_camera)
	
	if !_a_skip:
		queue_free()
	if _a_wait_finish && !_a_skip:
		_emit_completed()

func _tween_finished_object_to_point() -> void:
	if !_a_skip:
		queue_free()
	if _a_wait_finish && !_a_skip:
		_emit_completed()

func get_save_data() -> Dictionary:
	var free_camera: Node = _a_curr_scene.get_free_camera()
	_add_revert_property(free_camera, &"$Free_Camera", &"$Main", &"position")
	
	var data: Dictionary = super()
	var args: Dictionary = data[&"Args"]
	args[&"Type"] = _a_type
	args[&"Interpolate"] = _a_interpolate
	args[&"Elapsed_Time"] = _a_tween.get_total_elapsed_time()
	args[&"Duration_Factor"] = _a_duration_factor
	args[&"Trans_Type"] = _a_trans_type
	args[&"Ease_Type"] = _a_ease_type
	args[&"Wait_Finish"] = _a_wait_finish
	args[&"Start_Object_Key"] = _a_start_object_key
	args[&"End_Object_Key"] = _a_end_object_key
	args[&"Change_Camera"] = _a_change_camera
	args[&"Point_Selected"] = _a_point_selected
	args[&"Pos"] = _a_pos
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	var args: Dictionary = p_data[&"Args"]
	_a_type = args[&"Type"]
	_a_interpolate = args[&"Interpolate"]
	_a_elapsed_time = args[&"Elapsed_Time"]
	_a_duration_factor = args[&"Duration_Factor"]
	_a_trans_type = args[&"Trans_Type"]
	_a_ease_type = args[&"Ease_Type"]
	_a_wait_finish = args[&"Wait_Finish"]
	_a_start_object_key = args[&"Start_Object_Key"]
	_a_end_object_key = args[&"End_Object_Key"]
	_a_change_camera = args[&"Change_Camera"]
	_a_point_selected = args[&"Point_Selected"]
	_a_pos = args[&"Pos"]
	
	_process_command()

func _on_Tween_finished() -> void:
	match _a_type:
		&"Move_Route": _tween_finished_move_route()
		&"Object_To_Object": _tween_finished_object_to_object()
		&"Object_To_Point": _tween_finished_object_to_point()
