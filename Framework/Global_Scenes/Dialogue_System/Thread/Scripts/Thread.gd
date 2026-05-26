extends Node
class_name FWDialogueSystemThread

signal completed()

const _a_PROCESS_SCENE_PATH: String = "res://Framework/Global_Scenes/Dialogue_System/Thread/Process/Process_%s.tscn"

@onready var _a_Processes: Node = get_node("Processes")

var _a_key_type: StringName # Map/Global
var _a_key: StringName # Dialogue Key
var _a_caller: Node # Caller of Dialogue_System
var _a_completed_cb: Callable # Callback method to call on completion
var _a_choice_selected_cb: Callable # Callback method to call on choice selected
var _a_process_type: StringName # Main/Sub/Manual
var _a_idx: int = -1 # Current part idx
var _a_start_idx: int = -1 # Start part idx
var _a_end_idx: int = -1 # End part idx
var _a_layer: int = -1 # Layer of Process
var _a_fade_out: bool = true # Play Fade_Out Animation on finish?
var _a_instances_type: StringName # Key/Speech_Bubble
var _a_speech_bubbles = [] # Only needed if a_instances_type is Speech_Bubble

var _a_parts: Array[Dictionary] = []
var _a_play_vox: bool = true

func _ready() -> void:
	var dialogues_data: Dictionary = Databases.get_global_map_data(&"Dialogues", _a_key_type, &"", &"", self)
	var data: Dictionary = dialogues_data[_a_key][&"Data"]
	for args: Dictionary in data.values():
		_a_parts.push_back(args)
	
	# Set default values for idxs
	if _a_idx == -1:
		_a_idx = _a_start_idx
	if _a_end_idx == -1:
		_a_end_idx = _a_parts.size() - 1
	
	_process_next()

func manual_proceed() -> void:
	var child: FWDialogueSystemThreadProcessBase = _a_Processes.get_child(0)
	child.queue_free()
	
	_proceed()

func skip() -> void:
	var child: FWDialogueSystemThreadProcessBase = _a_Processes.get_child(0)
	var args: Dictionary = child.get_args()
	var type: StringName = args["Type"]
	if type == &"Choice":
		return
	
	child.reset()
	for i: int in range(_a_idx + 1, _a_end_idx):
		type = _a_parts[i][&"Type"]
		if type == &"Choice":
			_a_idx = i
			_process_next()
			return
	
	queue_free()
	completed.emit()

func _process_next() -> void:
	var args: Dictionary = _a_parts[_a_idx]
	var type: StringName = args[&"Type"]
	var instance: FWDialogueSystemThreadProcessBase = _instantiate_process(args, type)
	instance.set_fade_in(_get_fade_in(args, type))
	instance.set_fade_out(_get_fade_out(args, type))
	
	_a_Processes.add_child(instance)

func _proceed() -> void:
	_a_idx += 1
	if _a_idx > _a_end_idx:
		queue_free()
		completed.emit()
		return
	
	_process_next()

func _instantiate_process(p_args: Dictionary, p_type: StringName) -> FWDialogueSystemThreadProcessBase:
	var instance: FWDialogueSystemThreadProcessBase
	match p_type:
		&"Text":
			var general_type: StringName = p_args[&"Data"][&"Text"][&"General"][&"Type"]
			instance = _instantiate_process_text(p_type, general_type)
		_:
			var scene: PackedScene = load(_a_PROCESS_SCENE_PATH % p_type)
			instance = scene.instantiate()
	
	instance.choice_selected.connect(_on_Process_choice_selected)
	instance.completed.connect(_on_Process_completed)
	instance.set_type(p_type)
	instance.set_process_type(_a_process_type)
	instance.set_args(p_args)
	instance.set_play_vox(_a_play_vox)
	instance.set_process_mode_.call_deferred(process_mode)
	instance.set_layer(_a_layer)
	
	return instance

func _instantiate_process_text(p_type: StringName, p_general_type: StringName) -> FWDialogueSystemThreadProcessBase:
	var process_name: String = "%s_%s" % [p_type, p_general_type]
	var scene: PackedScene = load(_a_PROCESS_SCENE_PATH % process_name)
	var instance: FWDialogueSystemThreadProcessBase = scene.instantiate()
	match p_general_type:
		&"Object":
			instance.set_instance_type(_a_instances_type)
			
			# Pass Process instance provided speech bubble instance
			if _a_instances_type == &"Speech_Bubble":
				var speech_bubble
				if _a_idx > _a_speech_bubbles.size() - 1:
					speech_bubble = _a_speech_bubbles[-1]
				else:
					speech_bubble = _a_speech_bubbles[_a_idx]
				instance.set_speech_bubble(speech_bubble)
	
	return instance

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func set_caller(p_caller: Node) -> void:
	_a_caller = p_caller

func get_caller() -> Node:
	return _a_caller

func set_completed_cb(p_completed_cb: Callable) -> void:
	_a_completed_cb = p_completed_cb

func get_completed_cb() -> Callable:
	return _a_completed_cb

func set_choice_selected_cb(p_choice_selected_cb: Callable) -> void:
	_a_choice_selected_cb = p_choice_selected_cb

func get_choice_selected_cb() -> Callable:
	return _a_choice_selected_cb

func set_process_mode_(p_process_mode: ProcessMode) -> void:
	set_process_mode(p_process_mode)
	for child: FWDialogueSystemThreadProcessBase in _a_Processes.get_children():
		child.set_process_mode_(p_process_mode)

func set_layer(p_layer: int) -> void:
	_a_layer = p_layer
	for child: FWDialogueSystemThreadProcessBase in _a_Processes.get_children():
		child.set_layer(p_layer)

func set_process_type(p_process_type: StringName) -> void:
	_a_process_type = p_process_type

func get_process_type() -> StringName:
	return _a_process_type

func set_idx(p_idx: int) -> void:
	_a_idx = p_idx

func set_start_idx(p_start_idx: int) -> void:
	_a_start_idx = p_start_idx

func set_end_idx(p_end_idx: int) -> void:
	_a_end_idx = p_end_idx

func set_fade_out(p_fade_out: bool) -> void:
	_a_fade_out = p_fade_out

func set_key_type(p_key_type: StringName) -> void:
	_a_key_type = p_key_type

func set_instances_type(p_instances_type: StringName) -> void:
	_a_instances_type = p_instances_type

func set_speech_bubbles(p_speech_bubbles) -> void:
	_a_speech_bubbles = p_speech_bubbles

func set_play_vox(p_play_vox: bool) -> void:
	for child: FWDialogueSystemThreadProcessBase in _a_Processes.get_children():
		child.set_play_vox(p_play_vox)
	
	_a_play_vox = p_play_vox

func get_play_vox() -> bool:
	return _a_play_vox

func _get_fade_in(p_args: Dictionary, p_type: StringName) -> bool:
	# First Part
	if _a_idx == _a_start_idx:
		return true
	
	# Previous type different
	var prev_args: Dictionary = _a_parts[_a_idx - 1]
	var prev_type: StringName = prev_args[&"Type"]
	if prev_type != p_type:
		return true
	
	if p_type == &"Text":
		var general_type: StringName = p_args[&"Data"][p_type][&"General"][&"Type"]
		var prev_general_type: StringName = prev_args[&"Data"][p_type][&"General"][&"Type"]
		# Previous general type different
		if prev_general_type != general_type:
			return true
		
		# Previous object key different
		var object_key: StringName = p_args[&"Data"][p_type][&"Object"][&"Object"]
		var prev_object_key: StringName = prev_args[&"Data"][p_type][&"Object"][&"Object"]
		if prev_object_key != object_key:
			return true
	
	return false

func _get_fade_out(p_args: Dictionary, p_type: StringName) -> bool:
	# Fade out if:
	# - Next part is different type
	# (If type Text_Object also object key can be different)
	
	# Last part and a_fade_out
	if _a_idx == _a_end_idx:
		return _a_fade_out
	
	# Next type different
	var next_args: Dictionary = _a_parts[_a_idx + 1]
	var next_type: StringName = next_args[&"Type"]
	if next_type != p_type:
		return true
	
	if p_type == &"Text":
		var general_type: StringName = p_args[&"Data"][p_type][&"General"][&"Type"]
		var next_general_type: StringName = next_args[&"Data"][p_type][&"General"][&"Type"]
		# Next general type different
		if next_general_type != general_type:
			return true
		
		# Next object key different
		var object_key: StringName = p_args[&"Data"][p_type][&"Object"][&"Object"]
		var next_object_key: StringName = next_args[&"Data"][p_type][&"Object"][&"Object"]
		if next_object_key != object_key:
			return true
	
	return false

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Key_Type"] = _a_key_type
	data[&"Key"] = _a_key
	
	var caller_path: NodePath = NodePath()
	if is_instance_valid(_a_caller):
		caller_path = _a_caller.get_path()
	data[&"Caller_Path"] = caller_path
	
	var completed_cb_object_path: NodePath = NodePath()
	var completed_cb_name: StringName = &""
	if _a_completed_cb.is_valid():
		var completed_cb_object: Node = _a_completed_cb.get_object()
		completed_cb_object_path = completed_cb_object.get_path()
		completed_cb_name = _a_completed_cb.get_method()
	data[&"Completed_CB"] = {}
	data[&"Completed_CB"][&"Object_Path"] = completed_cb_object_path
	data[&"Completed_CB"][&"Name"] = completed_cb_name
	
	var choice_selected_cb_object_path: NodePath = NodePath()
	var choice_selected_cb_name: StringName = &""
	if _a_choice_selected_cb.is_valid():
		var choice_selected_cb_object: Node = _a_choice_selected_cb.get_object()
		choice_selected_cb_object_path = choice_selected_cb_object.get_path()
		choice_selected_cb_name = _a_choice_selected_cb.get_method()
	data[&"Choice_Selected_CB"] = {}
	data[&"Choice_Selected_CB"][&"Object_Path"] = choice_selected_cb_object_path
	data[&"Choice_Selected_CB"][&"Name"] = choice_selected_cb_name
	
	data[&"Process_Type"] = _a_process_type
	data[&"Process_Mode"] = get_process_mode()
	data[&"Idx"] = _a_idx
	data[&"Start_Idx"] = _a_start_idx
	data[&"End_Idx"] = _a_end_idx
	data[&"Layer"] = _a_layer
	data[&"Fade_Out"] = _a_fade_out
	data[&"Instances_Type"] = _a_instances_type
	data[&"Speech_Bubbles"] = _a_speech_bubbles
	
	return data

func _on_Process_choice_selected(p_value: Variant) -> void:
	if _a_choice_selected_cb.is_valid():
		_a_choice_selected_cb.call(_a_key, p_value)
	
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var part_entry_key: StringName = StringName(str(_a_idx))
	progress_si.set_dialogue_choice_value(_a_key_type, _a_key, part_entry_key, p_value)

func _on_Process_completed() -> void:
	_proceed()
