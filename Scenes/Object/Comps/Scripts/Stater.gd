extends Node
class_name CompStater

var _a_entity_comph: CompHandler

var _a_states: Dictionary # Match Map/Global to data
var _a_states_idx: int = -1 # Only process actions once
var _a_expr: Expression = Expression.new()

func init(p_entity: Node) -> void:
	_a_entity_comph = p_entity.comph()
	
	var global_si: Global = Global.get_singleton(self, "Global")
	if global_si.is_instance_in_game_world(self):
		var progress_si: Progress = Global.get_singleton(self, "Progress")
		var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
		progress_si.progress_changed.connect(_on_Progress_progress_changed)
		scene_manager_si.scene_changed.connect(_on_Scene_Manager_scene_changed)

func _init_states() -> void:
	# Set a_states based on states data in Databases
	var data: Dictionary = Databases.get_debug_data(&"Stater")
	var key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
	
	_a_states[&"Map"] = {}
	for chapter: StringName in data[&"Map"]:
		for location: StringName in data[&"Map"][chapter]:
			if data[&"Map"][chapter][location].has(key):
				var args: Dictionary = data[&"Map"][chapter][location][key]
				var states_args: Dictionary = _a_states[&"Map"].get_or_add(chapter, {})
				states_args[location] = args.duplicate(true)
	
	_a_states[&"Global"] = {}
	if data[&"Global"].has(key):
		var args: Dictionary = data[&"Global"][key]
		_a_states[&"Global"] = args.duplicate(true)

func _process_states() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var chapter: StringName = progress_si.get_chapter()
	var location: StringName = scene_manager_si.get_location()
	if !_a_states[&"Map"].has(chapter):
		return
	if !_a_states[&"Map"][chapter].has(location):
		return
	
	# Process as stack:
	# 1) Iterate backwards through data
	# 2) Check conditions until satisfied found
	# 3) Perform only this action
	# One_Time should be checked and executed individually
	var data: Dictionary = _a_states[&"Map"][chapter][location][&"Data"]
	var entry_keys: Array[StringName]; entry_keys.assign(data.keys())
	for i: int in range(entry_keys.size() - 1, -1, -1):
		var entry_key: StringName = entry_keys[i]
		var args: Dictionary = data[entry_key]
		var args_type: StringName = args[&"Type"]
		var args_data: Dictionary = args[&"Data"][args_type]
		
		var conds_met: bool = true
		for conds_entry_key: StringName in args_data[&"Conditions"]:
			var conds_args: Dictionary = args_data[&"Conditions"][conds_entry_key]
			if !_is_condition_satisfied(conds_args[&"Expression"]):
				conds_met = false
				break
		
		match args_type:
			&"General":
				if conds_met:
					if i != _a_states_idx:
						_a_states_idx = i
						_perform_actions(args_data[&"Actions"])
					break
			
			&"One_Time":
				if conds_met:
					# Remove state updates after execution
					# Done before Actions to avoid endless recursion
					data.erase(entry_keys[i])
					if _a_states_idx > i:
						_a_states_idx -= 1
					
					_perform_actions(args_data[&"Actions"])

func _is_condition_satisfied(p_args: Dictionary) -> bool:
	var key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
	var instance_key: StringName = p_args[&"Instance_Key"]
	var expression: String = p_args[&"Expression"]
	var instance: Node
	if instance_key == key:
		instance = self
	else:
		instance = Global.get_singleton(self, instance_key)
	
	var error: Error = _a_expr.parse(expression)
	if error == OK:
		var res: Variant = _a_expr.execute([], instance, false)
		if _a_expr.has_execute_failed():
			return false
		if !res:
			return false
	else:
		print(_a_expr.get_error_text())
		return false
	
	return true

func _perform_actions(p_data: Dictionary) -> void:
	var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var curr_scene: Node = scene_manager_si.get_curr_scene_instance()
	for act_entry_key: StringName in p_data:
		var act_args: Array[Dictionary]; act_args.assign(p_data[act_entry_key][&"Editor"])
		cutscene_system_si.cutscene_from_data(curr_scene, act_args, &"States")

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"States"] = _a_states
	data[&"States_Idx"] = _a_states_idx
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_states = p_data[&"States"]
	_a_states_idx = p_data[&"States_Idx"]

func load_data_init() -> void:
	# Only init states once per map
	_init_states()

func _on_Progress_progress_changed() -> void:
	_process_states()

func _on_Scene_Manager_scene_changed(_p_instance: Node, p_loaded_file_data: bool) -> void:
	if !p_loaded_file_data:
		await get_tree().process_frame
		_process_states()
