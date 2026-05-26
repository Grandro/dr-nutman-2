extends Node
class_name FWCutsceneSystem

signal main_started(p_key: StringName)
signal main_completed()
signal data_loaded()

@export var _e_thread_uids: Dictionary = {}

var _a_Branch_Scene: PackedScene = preload("uid://wuqihst5cpg")

@onready var _a_Branches: Node = get_node("Branches")
@onready var _a_Skip_CD: Timer = get_node("Skip_CD")

var _a_save_data: Dictionary = {}

var _a_main_active: bool = false
var _a_skipping_allowed: bool = true
var _a_branches: Dictionary = {} # Match cutscene key/entry_key to branch instance

func _ready() -> void:
	_a_Skip_CD.timeout.connect(_on_Skip_CD_timeout)
	
	set_process(false)

func _process(_p_delta: float) -> void:
	if !OS.is_debug_build():
		return
	if !_a_skipping_allowed:
		return
	
	if Input.is_action_pressed(&"Skip"):
		for child: FWCutsceneBranch in _a_Branches.get_children():
			var process_type: StringName = child.get_process_type()
			if process_type != &"Main" && process_type != &"Sub":
				continue
			
			child.skip()
			_a_skipping_allowed = false
			_a_Skip_CD.start()

func cutscene(p_key: StringName, p_entry_key: StringName, p_process_type: StringName = &"Main", p_key_type: StringName = &"Map") -> void:
	# p_key: Cutscene key
	# p_entry_key: Cutscene Entry key
	# p_process_type: Main/Sub
	# p_key_type: Map/Global
	
	# Stop active cutscene
	if _a_branches.has(p_key) && _a_branches[p_key].has(p_entry_key):
		var old_instance: FWCutsceneBranch = _a_branches[p_key][p_entry_key]
		_a_Branches.remove_child(old_instance)
		old_instance.queue_free()
	
	var cutscene_data: Dictionary = Databases.get_global_map_data(&"Cutscenes", p_key_type, &"", &"", self)
	var entry_key_data: Dictionary = cutscene_data[p_key][&"Data"][p_entry_key][&"Data"]
	var data: Array[Dictionary]; data.assign(entry_key_data[&"Default"].duplicate(true))
	if !_a_main_active && p_process_type == &"Main":
		_set_main_active(true)
		main_started.emit(p_key)
	
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var curr_scene: Node = scene_manager_si.get_curr_scene_instance()
	var instance: FWCutsceneBranch = _instantiate_branch(curr_scene, data, p_process_type, p_key, p_entry_key, p_key_type)
	_a_Branches.add_child(instance)

func cutscene_from_data(p_curr_scene: Node, p_data: Array[Dictionary], p_process_type: StringName, p_skip_idxs: Array[int] = []) -> void:
	if !_a_main_active && p_process_type == &"Main":
		_set_main_active(true)
		main_started.emit(&"")
	
	var args: Array[Dictionary] = p_data.duplicate(true)
	var instance: FWCutsceneBranch = _instantiate_branch(p_curr_scene, args, p_process_type, &"", &"", &"", p_skip_idxs)
	_a_Branches.add_child(instance)

func stop() -> void:
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.queue_free()
	if !_a_main_active:
		return
	
	_set_main_active(false)
	main_completed.emit()

func reset() -> void:
	_a_save_data.clear()
	_a_main_active = false
	_a_Skip_CD.stop()
	_a_skipping_allowed = true
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.queue_free()

func cleanup_map() -> void:
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.cleanup_map()
		if !child.get_persist():
			child.queue_free()

func _branch_completed(p_instance: FWCutsceneBranch) -> void:
	var main_active: bool = false
	for child: FWCutsceneBranch in _a_Branches.get_children():
		if !child.has_completed() && child.get_process_type() == &"Main":
			main_active = true
			break
	
	var process_type: StringName = p_instance.get_process_type()
	var completed_cb: Callable = p_instance.get_completed_cb()
	if completed_cb.is_valid():
		var key: StringName = p_instance.get_key()
		var entry_key: StringName = p_instance.get_entry_key()
		completed_cb.call(process_type, key, entry_key)
	
	if !main_active:
		_set_main_active(false)
		if process_type == &"Main":
			main_completed.emit()

func _instantiate_branch(p_curr_scene: Node, p_data: Array[Dictionary], p_process_type: StringName, p_key: StringName,
						 p_entry_key: StringName, p_key_type: StringName, p_skip_idxs: Array[int] = []) -> FWCutsceneBranch:
	var instance: FWCutsceneBranch = _a_Branch_Scene.instantiate()
	instance.command_changed.connect(_on_Branch_command_changed.bind(instance))
	instance.tree_exited.connect(_on_Branch_tree_exited)
	instance.tree_exiting.connect(_on_Branch_tree_exiting.bind(instance))
	instance.completed.connect(_on_Branch_completed.bind(instance))
	instance.request_exit.connect(_on_Branch_request_exit.bind(instance))
	instance.set_thread_uids(_e_thread_uids)
	instance.set_curr_scene(p_curr_scene)
	instance.set_data(p_data)
	instance.set_process_type(p_process_type)
	instance.set_key(p_key)
	instance.set_entry_key(p_entry_key)
	instance.set_key_type(p_key_type)
	instance.set_skip_idxs(p_skip_idxs)
	
	if !p_key.is_empty():
		if !_a_branches.has(p_key):
			_a_branches[p_key] = {}
		_a_branches[p_key][p_entry_key] = instance
	
	return instance

func get_option_value(p_data: Dictionary) -> Variant:
	var type: StringName = p_data[&"Type"]
	match type:
		&"Var":
			var global_si: Global = Global.get_singleton(self, "Global")
			var expression_data: Dictionary = p_data[&"Var"][&"Expression"]
			return global_si.execute_expr_from_data(expression_data)
		&"Value":
			return p_data[&"Value"]
	
	return null

func get_movement_base_speed(p_dim: StringName, p_speed: float) -> float:
	match p_dim:
		&"2D": return get_movement_base_speed_2D(p_speed)
		&"3D": return p_speed
	
	return -1.0

func get_movement_base_speed_2D(_p_speed: float) -> float:
	push_warning("Not implemented.")
	return -1.0

func get_movement_duration_factor(p_dim: StringName, p_speed: float) -> float:
	match p_dim:
		&"2D": return get_movement_duration_factor_2D(p_speed)
		&"3D": return get_movement_duration_factor_3D(p_speed)
	
	return -1.0

func get_movement_duration_factor_2D(p_speed: float) -> float:
	return 135.0 * p_speed

func get_movement_duration_factor_3D(p_speed: float) -> float:
	return 2.7 * p_speed

func set_cutscene_completed_cb(p_key: StringName, p_entry_key: StringName, p_completed_cb: Callable) -> void:
	var instance: FWCutsceneBranch = _a_branches[p_key][p_entry_key]
	instance.set_completed_cb(p_completed_cb)

func set_cutscene_process_mode(p_key: StringName, p_entry_key: StringName, p_process_mode: ProcessMode) -> void:
	var instance: FWCutsceneBranch = _a_branches[p_key][p_entry_key]
	instance.set_process_mode_(p_process_mode)

func set_cutscene_caller(p_key: StringName, p_entry_key: StringName, p_caller: Node) -> void:
	var instance: FWCutsceneBranch = _a_branches[p_key][p_entry_key]
	instance.set_caller(p_caller)

func get_cutscene_caller(p_key: StringName, p_entry_key: StringName) -> Node:
	var branch: FWCutsceneBranch = _a_branches[p_key][p_entry_key]
	var caller: Node = branch.get_caller()
	
	return caller

func get_cutscene_caller_key(p_key: StringName, p_entry_key: StringName) -> StringName:
	var caller: Node = get_cutscene_caller(p_key, p_entry_key)
	var key: String = caller.comph().call_comp("Reference", &"get_key")
	
	return key

func _set_main_active(p_active: bool) -> void:
	_a_main_active = p_active
	set_process(p_active)

func get_save_data(p_location: StringName, p_for_file: bool) -> Dictionary:
	_a_save_data[p_location] = {}
	var data: Dictionary = _a_save_data[p_location]
	
	data[&"Main_Active"] = _a_main_active
	data[&"Branches"] = []
	for child: FWCutsceneBranch in _a_Branches.get_children():
		if child.is_queued_for_deletion():
			continue
		var save_data: Dictionary = child.get_save_data(p_for_file)
		data[&"Branches"].push_back(save_data)
		
		if !p_for_file && !child.get_persist():
			child.queue_free()
	
	return _a_save_data

func load_file_data(p_data: Dictionary) -> void:
	_a_save_data = p_data

func load_data(p_location: StringName, p_for_file: bool) -> void:
	if !_a_save_data.has(p_location):
		data_loaded.emit()
		return
	
	var save_data: Dictionary = _a_save_data[p_location]
	_set_main_active(save_data[&"Main_Active"])
	
	var branches_data: Array[Dictionary]; branches_data.assign(save_data[&"Branches"])
	for i: int in branches_data.size():
		var args: Dictionary = branches_data[i]
		var instance: FWCutsceneBranch
		var process_type: StringName
		var key: StringName
		var persist: bool = args[&"General"][&"Persist"]
		if !p_for_file && persist:
			# The branch still exists
			var self_path: NodePath = args[&"General"][&"Self_Path"]
			instance = get_node(self_path)
			process_type = instance.get_process_type()
			key = instance.get_key()
		else:
			# Create new branch
			process_type = args[&"General"][&"Process_Type"]
			key = args[&"General"][&"Key"]
			
			var entry_key: StringName = args[&"General"][&"Entry_Key"]
			var key_type: StringName = args[&"General"][&"Key_Type"]
			var cutscene_data: Dictionary = Databases.get_global_map_data(&"Cutscenes", key_type, &"", &"", self)
			var data: Array[Dictionary] = cutscene_data[key][&"Data"][entry_key][&"Data"][&"Default"].duplicate(true)
			var caller_path: NodePath = args[&"General"][&"Caller_Path"]
			var caller: Node = get_node_or_null(caller_path)
			
			var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
			var curr_scene: Node = scene_manager_si.get_curr_scene_instance()
			instance = _instantiate_branch(curr_scene, data, process_type, key, entry_key, key_type)
			set_cutscene_caller(key, entry_key, caller)
		
		if i == branches_data.size() - 1:
			instance.data_loaded.connect(_on_Branches_data_loaded)
		instance.set_loads_data(true)
		instance.load_data(args, p_for_file)
		
		if !persist || p_for_file:
			_a_Branches.add_child(instance)
	
	if branches_data.is_empty():
		data_loaded.emit()

func _on_Skip_CD_timeout() -> void:
	_a_skipping_allowed = true

func _on_Branch_command_changed(p_instance: FWCutsceneBranch) -> void:
	var command: StringName = p_instance.get_command()
	var idx: int = p_instance.get_index()
	p_instance.set_name("%s_%d" % [command, idx])

func _on_Branch_tree_exited() -> void:
	for child: FWCutsceneBranch in _a_Branches.get_children():
		var command: StringName = child.get_command()
		var idx: int = child.get_index()
		child.set_name("%s_%d" % [command, idx])

func _on_Branch_tree_exiting(p_instance: FWCutsceneBranch) -> void:
	var key: StringName = p_instance.get_key()
	if key == &"":
		return
	
	var entry_key: StringName = p_instance.get_entry_key()
	_a_branches[key].erase(entry_key)
	if _a_branches[key].is_empty():
		_a_branches.erase(key)

func _on_Branch_completed(p_instance: FWCutsceneBranch) -> void:
	_branch_completed(p_instance)

func _on_Branch_request_exit(p_instance: FWCutsceneBranch) -> void:
	_branch_completed(p_instance)
	p_instance.queue_free()

func _on_Branches_data_loaded() -> void:
	data_loaded.emit()
