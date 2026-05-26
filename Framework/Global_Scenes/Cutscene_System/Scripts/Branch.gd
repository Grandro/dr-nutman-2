extends Node
class_name FWCutsceneBranch

signal command_changed()
signal completed()
signal sub_process_completed(p_id_ord: StringName)
signal request_exit()
signal data_loaded()
signal persist_changed()

var _a_Branch_Scene: PackedScene = load("uid://wuqihst5cpg")

@onready var _a_Branches: Node = get_node("Branches")
@onready var _a_Threads: Node = get_node("Threads")

var _a_thread_uids: Dictionary # Scene uids to Threads 2D/3D
var _a_dim: StringName # 2D/3D
var _a_curr_scene: Node # Current scene instance
var _a_command: StringName # Command of current thread
var _a_process_type: StringName # Main/Sub/Stater
var _a_key: StringName # Cutscene key
var _a_entry_key: StringName # Cutscene Entry key
var _a_key_type: StringName # Global/Map
var _a_caller: Node # Caller of Cutscene_System
var _a_completed_cb: Callable # Callback method on completion
var _a_skip_idxs: Array[int] # Stores to which command this branch should skip
var _a_skip: bool = false # Skip this branch?

var _a_data_origin: Array[Array] # Where in the original cutscene data does this data come from?
var _a_data: Array[Dictionary] # Command data of this branch
var _a_data_idx: int = -1 # Command idx in _a_data to process
var _a_completed: bool = false # Main branch has finished

var _a_persist: bool = false # Don't delete this branch on map change
var _a_loads_data: bool = false # Don't process next command if this loads data

var _a_branches_loaded: bool = false # Finished loading branches?
var _a_threads_loaded: bool = false # Finished loading threads?

# Additional arguments for certain commands
# Teleport
var _a_tp_type: StringName
var _a_tp_branches: Dictionary
var _a_tp_teleportation: StringName
var _a_tp_return_location: StringName
var _a_tp_handle_lost_battle: bool
var _a_tp_branch: int

# Loop
var _a_l_key: StringName
var _a_l_first: bool = true # First iteration of loop?
# Loop_For
var _a_lf_step: int
var _a_lf_iters: int = -1

# Sub_Process
var _a_id: StringName
# ------------------------------------

func _ready() -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	scene_manager_si.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	_a_dim = scene_manager_si.get_curr_scene_dim()
	if _a_data.is_empty():
		_a_completed = true
		completed.emit()
		queue_free()
		return
	
	if !_a_loads_data:
		_process_next_command(true)

func skip() -> void:
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.skip.call_deferred()
	for child: FWCutsceneThreadBase in _a_Threads.get_children():
		child.skip.call_deferred()

func cleanup_map() -> void:
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.cleanup_map()
		if !child.get_persist():
			child.queue_free()

func handle_sub_process_threads(p_id_ord: StringName) -> void:
	for child: FWCutsceneThreadBase in _a_Threads.get_children():
		var command: StringName = child.get_command()
		if command == &"Wait_For_Sub_Process":
			child.sub_process_completed(p_id_ord)

func _process_next_command(p_inc: bool) -> void:
	if p_inc:
		_a_data_idx += 1
	
	if _a_data_idx == _a_data.size():
		_a_completed = true
		completed.emit()
		return
	
	var data: Dictionary = _a_data[_a_data_idx]
	_a_command = data[&"Command"]
	command_changed.emit()
	
	if _a_skip_idxs.size() == 1:
		var idx: int = _a_skip_idxs[0]
		_a_skip = idx > _a_data_idx
	elif _a_skip_idxs.size() >= 2:
		_a_skip = true
	
	# Fight Stack Overflow
	if _a_skip && _a_data_idx % 100 == 0:
		await get_tree().process_frame
	
	match _a_command:
		&"Cond_Branch": _process_cond_branch(data[&"Data"], data[&"Args"])
		&"Teleport": _process_teleport(data[&"Data"], data[&"Args"])
		&"Match": _process_match(data[&"Data"], data[&"Args"])
		&"Loop": _process_loop(data[&"Data"], data[&"Args"])
		&"Sub_Process": _process_sub_process(data[&"Data"], data[&"Args"])
		_: 
			var instance: FWCutsceneThreadBase = _instantiate_thread(data[&"Data"], _a_command)
			_a_Threads.add_child(instance)

func _process_cond_branch(p_data: Dictionary, p_args: Dictionary) -> void:
	# Execute condition and instance new branch
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var key: StringName = p_data[&"Key"]
	var else_branch: bool = p_data[&"Else_Branch"]
	var menu_data: Dictionary = p_data[&"Menus"][key]
	var branch: int = -1
	match key:
		&"Items":
			var item_key: StringName = cutscene_system_si.get_option_value(menu_data[&"Item"])
			var amount_args: Dictionary = cutscene_system_si.get_option_value(menu_data[&"Amount"])
			var item_min: int = cutscene_system_si.get_option_value(amount_args[&"Min"])
			var item_max: int = cutscene_system_si.get_option_value(amount_args[&"Max"])
			var has_item: bool = global_si.has_item(item_key, item_min, item_max)
			if has_item:
				branch = 0
			elif else_branch:
				branch = 1
			
		&"Script":
			var res: Variant = global_si.execute_expr_from_data(menu_data)
			if res:
				branch = 0
			elif else_branch:
				branch = 1
	
	var branches: Dictionary = p_args[&"Branches"]
	if branches.has(branch):
		var branch_data: Array[Dictionary]; branch_data.assign(branches[branch][&"Entries"])
		var instance: FWCutsceneBranch = _instantiate_branch(branch, branch_data)
		_a_Branches.add_child(instance)
	else:
		_process_next_command(true)

func _process_teleport(p_data: Dictionary, p_args: Dictionary) -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	_a_tp_return_location = scene_manager_si.get_location()
	_a_tp_type = cutscene_system_si.get_option_value(p_data[&"Type"])
	match _a_tp_type:
		&"Map":
			var instance: FWCutsceneThreadBase = _instantiate_thread(p_data, _a_command)
			_a_Threads.add_child(instance)
		
		&"Battle":
			set_persist(true)
			_a_tp_teleportation = cutscene_system_si.get_option_value(p_data[&"Teleportation"])
			_a_tp_handle_lost_battle = cutscene_system_si.get_option_value(p_data[&"Handle_Lost_Battle"])
			_a_tp_branches = p_args[&"Branches"]
			var troop: Array[StringName]; troop.assign(cutscene_system_si.get_option_value(p_data[&"Troop"]))
			
			var battle_system_si: Battle_System = Global.get_singleton(self, "Battle_System")
			var battle_sv: BattleSV = battle_system_si.get_battle_sv()
			battle_sv.battle_ended.connect(_on_Battle_SV_battle_ended)
			battle_sv.battle(_a_tp_teleportation, BattleSV.MAP_RES.NEUTRAL, troop)

func _process_match(p_data: Dictionary, p_args: Dictionary) -> void:
	# Execute condition and instance new branch
	var key: StringName = p_data[&"Key"]
	var menu_data: Dictionary = p_data[&"Menus"][key]
	var branches_values: Array = menu_data[&"Branches_Values"]
	var branch: int
	match key:
		&"Choices":
			var progress_si: Progress = Global.get_singleton(self, "Progress")
			var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
			var key_type: StringName = cutscene_system_si.get_option_value(menu_data[&"Key_Type"])
			var chapter: StringName = cutscene_system_si.get_option_value(menu_data[&"Chapter"])
			var location: StringName = cutscene_system_si.get_option_value(menu_data[&"Location"])
			var dialogue_key: StringName = cutscene_system_si.get_option_value(menu_data[&"Dialogue"])
			var part_entry_key: StringName = cutscene_system_si.get_option_value(menu_data[&"Part"])
			var value: Variant = progress_si.get_dialogue_choice_value(key_type, chapter, location, dialogue_key, part_entry_key)
			branch = branches_values.find(value) + 1
		
		&"Script":
			var global_si: Global = Global.get_singleton(self, "Global")
			var res: Variant = global_si.execute_expr_from_data(menu_data[&"Expression"])
			branch = branches_values.find(res) + 1
	
	var branches: Dictionary = p_args[&"Branches"]
	var branch_data: Array[Dictionary]; branch_data.assign(branches[branch][&"Entries"])
	var branch_instance: FWCutsceneBranch = _instantiate_branch(branch, branch_data)
	_a_Branches.add_child(branch_instance)

func _process_loop(p_data: Dictionary, p_args: Dictionary) -> void:
	var key: StringName = p_data[&"Key"]
	var args: Dictionary = p_data[&"Args"]
	match key:
		&"For":
			var global_si: Global = Global.get_singleton(self, "Global")
			var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
			var idx: String = cutscene_system_si.get_option_value(args[&"Idx"])
			_a_lf_step = cutscene_system_si.get_option_value(args[&"Step"])
			if _a_lf_iters == -1:
				var start: int = cutscene_system_si.get_option_value(args[&"Start"])
				var end: int = cutscene_system_si.get_option_value(args[&"End"])
				_a_lf_iters = int(floor(end - start) / _a_lf_step) + 1
				global_si.a_for_loop_idxs[idx] = start
			else:
				_a_l_first = false
				global_si.a_for_loop_idxs[idx] += _a_lf_step
			
			_a_lf_iters -= 1
	_a_l_key = key
	
	var branches: Dictionary = p_args[&"Branches"]
	var branch_data: Array[Dictionary]; branch_data.assign(branches[0][&"Entries"])
	var instance: FWCutsceneBranch = _instantiate_branch(0, branch_data)
	_a_Branches.add_child(instance)

func _process_sub_process(p_data: Dictionary, p_args: Dictionary) -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	_a_id = cutscene_system_si.get_option_value(p_data[&"ID"])
	var branches: Dictionary = p_args[&"Branches"]
	var branch_data: Array[Dictionary]; branch_data.assign(branches[0][&"Entries"])
	var instance: FWCutsceneBranch = _instantiate_branch(0, branch_data)
	_a_Branches.add_child(instance)
	
	_process_next_command(true)

func _instantiate_branch(p_branch: int, p_data: Array[Dictionary]) -> FWCutsceneBranch:
	var data_origin: Array[Array] = _a_data_origin.duplicate()
	data_origin.push_back([_a_data_idx, p_branch])
	
	var instance: FWCutsceneBranch = _a_Branch_Scene.instantiate()
	instance.command_changed.connect(_on_Branch_command_changed.bind(instance))
	instance.tree_exited.connect(_on_Branch_tree_exited)
	instance.completed.connect(_on_Branch_completed.bind(_a_command))
	instance.sub_process_completed.connect(_on_Branch_sub_process_completed)
	instance.request_exit.connect(_on_Branch_request_exit)
	instance.persist_changed.connect(_on_Branch_persist_changed)
	instance.set_thread_uids(_a_thread_uids)
	instance.set_curr_scene(_a_curr_scene)
	instance.set_process_type(_a_process_type)
	instance.set_key(_a_key)
	instance.set_entry_key(_a_entry_key)
	instance.set_key_type(_a_key_type)
	instance.set_caller(_a_caller)
	instance.set_data_origin(data_origin)
	instance.set_data(p_data)
	instance.set_process_mode(process_mode)
	
	var skip_idxs: Array[int] = _a_skip_idxs.duplicate()
	if !skip_idxs.is_empty():
		var curr_idx: int = skip_idxs[0]
		if _a_data_idx == curr_idx:
			skip_idxs.pop_front()
		else:
			skip_idxs.clear()
	
	match _a_command:
		&"Loop":
			# Only skip in first loop iteration!
			if !_a_l_first && skip_idxs.size() == 1:
				instance.set_skip_idxs([])
				instance.set_skip(false)
			else:
				instance.set_skip_idxs(skip_idxs)
				instance.set_skip(_a_skip)
		_:
			instance.set_skip_idxs(skip_idxs)
			instance.set_skip(_a_skip)
	
	return instance

func _instantiate_thread(p_args: Dictionary, p_command: StringName, p_loads: bool = false) -> FWCutsceneThreadBase:
	var path: String = _a_thread_uids[p_command][_a_dim]
	var scene: PackedScene = load(path)
	var instance: FWCutsceneThreadBase = scene.instantiate()
	instance.ready.connect(_on_Thread_ready.bind(instance))
	instance.tree_exited.connect(_on_Thread_tree_exited)
	instance.completed.connect(_on_Thread_completed)
	if p_command == &"Exit_Cutscene":
		instance.request_exit.connect(_on_Thread_request_exit)
	instance.set_curr_scene(_a_curr_scene)
	instance.set_command(p_command)
	instance.set_skip(_a_skip)
	instance.set_process_mode(process_mode)
	
	if p_loads:
		instance.set_loads_data(true)
		instance.load_data.call_deferred(p_args)
	else:
		instance.set_args(p_args)
	
	return instance

func _sub_process_completed(p_id_ord: StringName) -> void:
	# Called when any child branch completes sub_process
	# -> Tell all threads and child branch threads
	handle_sub_process_threads(p_id_ord)
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.handle_sub_process_threads(p_id_ord)
	sub_process_completed.emit(p_id_ord)

func _teleport_completed() -> void:
	set_persist(false)
	
	match _a_tp_type:
		&"Battle":
			if _a_tp_branches.has(_a_tp_branch):
				var branch_data: Array[Dictionary] = _a_tp_branches[_a_tp_branch][&"Entries"]
				var instance: FWCutsceneBranch = _instantiate_branch(_a_tp_branch, branch_data)
				_a_Branches.add_child(instance)
			else:
				_process_next_command(true)

func _branches_loaded() -> void:
	_a_branches_loaded = true
	if _a_threads_loaded:
		data_loaded.emit()

func _threads_loaded() -> void:
	_a_threads_loaded = true
	if _a_branches_loaded:
		data_loaded.emit()

func set_thread_uids(p_thread_uids: Dictionary) -> void:
	_a_thread_uids = p_thread_uids

func set_curr_scene(p_curr_scene: Node) -> void:
	_a_curr_scene = p_curr_scene

func get_command() -> StringName:
	return _a_command

func set_process_type(p_process_type: StringName) -> void:
	_a_process_type = p_process_type

func get_process_type() -> StringName:
	return _a_process_type

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func set_entry_key(p_entry_key: StringName) -> void:
	_a_entry_key = p_entry_key

func get_entry_key() -> StringName:
	return _a_entry_key

func set_key_type(p_key_type: StringName) -> void:
	_a_key_type = p_key_type

func set_caller(p_caller: Node) -> void:
	_a_caller = p_caller

func get_caller() -> Node:
	return _a_caller

func set_completed_cb(p_completed_cb: Callable) -> void:
	_a_completed_cb = p_completed_cb

func get_completed_cb() -> Callable:
	return _a_completed_cb

func set_skip_idxs(p_skip_idxs: Array[int]) -> void:
	_a_skip_idxs = p_skip_idxs

func set_skip(p_skip: bool) -> void:
	_a_skip = p_skip

func set_data_origin(p_data_origin: Array[Array]) -> void:
	_a_data_origin = p_data_origin

func set_data(p_data: Array[Dictionary]) -> void:
	_a_data = p_data

func has_completed() -> bool:
	return _a_completed

func set_persist(p_persist: bool) -> void:
	_a_persist = p_persist
	
	if p_persist:
		persist_changed.emit()
	else:
		for child: FWCutsceneBranch in _a_Branches.get_children():
			child.set_persist(false)

func get_persist() -> bool:
	return _a_persist

func set_loads_data(p_loads_data: bool) -> void:
	_a_loads_data = p_loads_data

func set_process_mode_(p_process_mode: ProcessMode) -> void:
	set_process_mode(p_process_mode)
	for child: FWCutsceneBranch in _a_Branches.get_children():
		child.set_process_mode_(p_process_mode)
	for child: FWCutsceneThreadBase in _a_Threads.get_children():
		child.set_process_mode(p_process_mode)

func get_save_data(p_for_file: bool) -> Dictionary:
	var data: Dictionary = {}
	data[&"General"] = _get_general_save_data(p_for_file)
	data[&"Branches"] = _get_branches_save_data(p_for_file)
	data[&"Threads"] = _get_threads_save_data(p_for_file)
	
	return data

func _get_general_save_data(p_for_file: bool) -> Dictionary:
	var data: Dictionary = {}
	data[&"Persist"] = _a_persist
	
	if p_for_file || !_a_persist:
		data[&"Command"] = _a_command
		data[&"Process_Type"] = _a_process_type
		data[&"Process_Mode"] = get_process_mode()
		data[&"Key"] = _a_key
		data[&"Entry_Key"] = _a_entry_key
		data[&"Key_Type"] = _a_key_type
		
		var caller_path: NodePath = NodePath()
		if is_instance_valid(_a_caller):
			caller_path = _a_caller.get_path()
		data[&"Caller_Path"] = caller_path
		
		var completed_cb_object_path: NodePath = NodePath()
		var completed_cb_name: StringName = ""
		if _a_completed_cb.is_valid():
			var completed_cb_object: Node = _a_completed_cb.get_object()
			completed_cb_object_path = completed_cb_object.get_path()
			completed_cb_name = _a_completed_cb.get_method()
		data[&"Completed_CB"] = {}
		data[&"Completed_CB"][&"Object_Path"] = completed_cb_object_path
		data[&"Completed_CB"][&"Name"] = completed_cb_name
		
		data[&"Data_Origin"] = _a_data_origin
		data[&"Data_Idx"] = _a_data_idx
		data[&"Completed"] = _a_completed
		
		data[&"Args"] = {}
		data[&"Args"][&"Teleport"] = {}
		var tp_args: Dictionary = data[&"Args"][&"Teleport"]
		tp_args[&"Type"] = _a_tp_type
		tp_args[&"Branches"] = _a_tp_branches
		tp_args[&"Teleportation"] = _a_tp_teleportation
		tp_args[&"Return_Location"] = _a_tp_return_location
		tp_args[&"Handle_Lost_Battle"] = _a_tp_handle_lost_battle
		tp_args[&"Branch"] = _a_tp_branch
		
		data[&"Args"][&"Loop"] = {}
		var l_args: Dictionary = data[&"Args"][&"Loop"]
		l_args[&"Key"] = _a_l_key
		l_args[&"For"] = {}
		l_args[&"For"][&"Step"] = _a_lf_step
		l_args[&"For"][&"Iters"] = _a_lf_iters
		
		data[&"Args"][&"Sub_Process"] = {}
		var sp_args: Dictionary = data[&"Args"][&"Sub_Process"]
		sp_args[&"ID"] = _a_id
	else:
		data[&"Self_Path"] = get_path()
	
	return data

func _get_branches_save_data(p_for_file: bool) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for child: FWCutsceneBranch in _a_Branches.get_children():
		if child.is_queued_for_deletion():
			continue
		var save_data: Dictionary = child.get_save_data(p_for_file)
		data.push_back(save_data)
		if !p_for_file && !child.get_persist():
			child.queue_free()
	
	return data

func _get_threads_save_data(p_for_file: bool) -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	if p_for_file || !_a_persist:
		for child: FWCutsceneThreadBase in _a_Threads.get_children():
			if child.is_queued_for_deletion():
				continue
			var save_data: Dictionary = child.get_save_data()
			data.push_back(save_data)
	
	return data

func load_data(p_data: Dictionary, p_for_file: bool) -> void:
	_load_general_data.call_deferred(p_data[&"General"], p_for_file)
	_load_branches_data.call_deferred(p_data[&"Branches"], p_for_file)
	_load_threads_data.call_deferred(p_data[&"Threads"])

func _load_general_data(p_data: Dictionary, p_for_file: bool) -> void:
	_a_persist = p_data[&"Persist"]
	if p_for_file || !_a_persist:
		var completed_cb_object_path: NodePath = p_data[&"Completed_CB"][&"Object_Path"]
		var completed_cb_object: Node = get_node_or_null(completed_cb_object_path)
		if completed_cb_object != null:
			var completed_cb_name: StringName = p_data[&"Completed_CB"][&"Name"]
			_a_completed_cb = Callable(completed_cb_object, completed_cb_name)
		
		_a_command = p_data[&"Command"]
		_a_process_type = p_data[&"Process_Type"]
		set_process_mode_.call_deferred(p_data[&"Process_Mode"])
		_a_data_origin = p_data[&"Data_Origin"]
		_a_data_idx = p_data[&"Data_Idx"]
		_a_completed = p_data[&"Completed"]
		
		var args: Dictionary = p_data[&"Args"]
		# Teleport
		_a_tp_type = args[&"Teleport"][&"Type"]
		_a_tp_branches = args[&"Teleport"][&"Branches"]
		_a_tp_teleportation = args[&"Teleport"][&"Teleportation"]
		_a_tp_return_location = args[&"Teleport"][&"Return_Location"]
		_a_tp_handle_lost_battle = args[&"Teleport"][&"Handle_Lost_Battle"]
		_a_tp_branch = args[&"Teleport"][&"Branch"]
		
		# Loop
		_a_l_key = args[&"Loop"][&"Key"]
		# Loop_For
		_a_lf_step = args[&"Loop"][&"For"][&"Step"]
		_a_lf_iters = args[&"Loop"][&"For"][&"Iters"]
		
		# Sub_Process
		_a_id = args[&"Sub_Process"][&"ID"]
		
		command_changed.emit()

func _load_branches_data(p_data: Array[Dictionary], p_for_file: bool) -> void:
	for i: int in p_data.size():
		var args: Dictionary = p_data[i]
		var instance: FWCutsceneBranch
		var persist: bool = args[&"General"][&"Persist"]
		if !p_for_file && persist:
			# The branch still exists
			var self_path: NodePath = args[&"General"][&"Self_Path"]
			instance = get_node(self_path)
		else:
			var data_origin: Array[Array] = args[&"General"][&"Data_Origin"]
			var cutscene_data: Dictionary = Databases.get_global_map_data(&"Cutscenes", _a_key_type, &"", &"", self)
			var data: Array[Dictionary]; data.assign(cutscene_data[_a_key][&"Data"][_a_entry_key][&"Data"][&"Default"].duplicate(true))
			for origin_args: Array in data_origin:
				var idx: int = origin_args[0]
				var branch: int = origin_args[1]
				data.assign(data[idx][&"Args"][&"Branches"][branch][&"Entries"])
			instance = _instantiate_branch(data_origin[-1][1], data)
		
		if i == p_data.size() - 1:
			instance.data_loaded.connect(_on_Branches_data_loaded)
		instance.set_loads_data(true)
		instance.load_data(args, p_for_file)
		
		if p_for_file || !persist:
			_a_Branches.add_child(instance)
	
	if p_data.is_empty():
		_branches_loaded()

func _load_threads_data(p_data: Array[Dictionary]) -> void:
	for i: int in p_data.size():
		var args: Dictionary = p_data[i]
		var command: StringName = args[&"Command"]
		var instance: FWCutsceneThreadBase = _instantiate_thread(args, command, true)
		if i == p_data.size() - 1:
			instance.ready.connect(_on_Threads_data_loaded)
		_a_Threads.add_child(instance)
	
	if p_data.is_empty():
		_threads_loaded()

func _on_Branch_command_changed(p_instance: FWCutsceneBranch) -> void:
	var command: StringName = p_instance.get_command()
	var idx: int = p_instance.get_index()
	p_instance.set_name("%s_%d" % [command, idx])

func _on_Branch_tree_exited() -> void:
	for child: FWCutsceneBranch in _a_Branches.get_children():
		var command: StringName = child.get_command()
		var idx: int = child.get_index()
		child.set_name.call_deferred("%s_%d" % [command, idx])
	
	if _a_data_idx == _a_data.size():
		if _a_Branches.get_child_count() == 0:
			if _a_Threads.get_child_count() == 0:
				queue_free()

func _on_Branch_completed(p_command: StringName) -> void:
	if _a_completed:
		return
	
	match p_command:
		&"Sub_Process":
			_sub_process_completed(_a_id)
		&"Loop":
			match _a_l_key:
				&"For":
					var inc: bool = _a_lf_iters == 0
					_process_next_command(inc)
		_:
			_process_next_command(true)

func _on_Branch_sub_process_completed(p_id_ord: StringName) -> void:
	_sub_process_completed(p_id_ord)

func _on_Branch_request_exit() -> void:
	_a_completed = true
	request_exit.emit()

func _on_Branch_persist_changed() -> void:
	set_persist(true)

func _on_Branches_data_loaded() -> void:
	_branches_loaded()

func _on_Thread_ready(p_instance: FWCutsceneThreadBase) -> void:
	var command: StringName = p_instance.get_command()
	var idx: int = p_instance.get_index()
	p_instance.set_name("%s_%d" % [command, idx])

func _on_Thread_tree_exited() -> void:
	for child: FWCutsceneThreadBase in _a_Threads.get_children():
		var command: StringName = child.get_command()
		var idx: int = child.get_index()
		child.set_name("%s_%d" % [command, idx])
	
	if _a_data_idx == _a_data.size():
		if _a_Branches.get_child_count() == 0:
			if _a_Threads.get_child_count() == 0:
				queue_free()

func _on_Thread_completed() -> void:
	_process_next_command(true)

func _on_Thread_request_exit() -> void:
	_a_completed = true
	request_exit.emit()

func _on_Threads_data_loaded() -> void:
	_threads_loaded()

func _on_Battle_SV_battle_ended(p_location: StringName, p_res: StringName) -> void:
	if _a_tp_teleportation != p_location:
		return
	
	match p_res:
		&"Win":
			_a_tp_branch = 1
		&"Loss":
			if _a_tp_handle_lost_battle:
				_a_tp_branch = 2

func _on_Scene_Manager_scene_changed(p_instance: Node, _p_loaded_file_data: bool) -> void:
	set_curr_scene(p_instance)
	for child: FWCutsceneThreadBase in _a_Threads.get_children():
		child.set_curr_scene(p_instance)
	
	if _a_command == &"Teleport":
		var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
		var location: StringName = scene_manager_si.get_location()
		if location == _a_tp_return_location:
			_teleport_completed()
