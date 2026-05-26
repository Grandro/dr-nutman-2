extends Node
class_name FWDialogueSystem

signal main_started(p_key: StringName)
signal main_completed()

var _a_Thread_Scene: PackedScene = preload("uid://bddki7b1alyx8")

@onready var _a_Threads: Node = get_node("Threads")

var _a_save_data: Dictionary = {}

var _a_main_active: bool = false
var _a_threads: Dictionary[StringName, FWDialogueSystemThread] = {} # Match dialogue key to thread instance

func dialogue(p_key: StringName, p_caller: Node = null, p_process_type: StringName = &"Main", p_fade_out: bool = true,
			  p_start_idx: int = 0, p_end_idx: int = -1, p_key_type: StringName = &"Map") -> void:
	# p_key: Dialogue key
	# p_caller: Caller of dialogue
	# p_process_type: Main/Sub
	# p_fade_out: Fade out on dialogue completion?
	# p_key_type: Map/Global?
	
	var instance: FWDialogueSystemThread = _instantiate_thread(p_key, p_caller, p_process_type, p_start_idx,
															   p_end_idx, p_fade_out, p_key_type, &"Key")
	_update_threads_vox(instance, p_process_type)
	
	if !_a_main_active && p_process_type == &"Main":
		_a_main_active = true
		main_started.emit(p_key)
	
	_a_Threads.add_child(instance)

func dialogue_speech_bubbles(p_key: StringName, p_speech_bubbles, p_caller: Node = null, p_process_type: StringName = &"Main",
							p_start_idx: int = 0, p_end_idx: int = -1, p_fade_out: bool = true, p_key_type: StringName = &"Map") -> void:
	# p_key : Dialogue key
	# p_caller : Callback instance
	# p_process_type : Main/Sub
	# p_fade_out : Fade out on dialogue completion?
	# p_key_type : Map/Global Key in Chapter/Location or Global?
	
	var instance: FWDialogueSystemThread = _instantiate_thread(p_key, p_caller, p_process_type, p_start_idx,
															   p_end_idx, p_fade_out, p_key_type, &"Speech_Bubble",
															   p_speech_bubbles)
	_update_threads_vox(instance, p_process_type)
	
	if !_a_main_active && p_process_type == &"Main":
		_a_main_active = true
		main_started.emit(p_key)
	
	_a_Threads.add_child(instance)

func manual_proceed(p_key: StringName) -> void:
	var thread: FWDialogueSystemThread = _a_threads[p_key]
	thread.manual_proceed()

func skip(p_key: StringName) -> void:
	var thread: FWDialogueSystemThread = _a_threads[p_key]
	thread.skip()

func stop() -> void:
	_a_threads.clear()
	for child: FWDialogueSystemThread in _a_Threads.get_children():
		child.queue_free()
	
	if _a_main_active:
		main_completed.emit()
		_a_main_active = false

func _instantiate_thread(p_key: StringName, p_caller: Node, p_process_type: StringName, p_start_idx: int, p_end_idx: int,
						 p_fade_out: bool, p_key_type: StringName, p_instances_type: StringName, p_speech_bubbles = []) -> FWDialogueSystemThread:
	var instance: FWDialogueSystemThread = _a_Thread_Scene.instantiate()
	instance.completed.connect(_on_Thread_completed.bind(instance))
	instance.set_key(p_key)
	instance.set_caller(p_caller)
	instance.set_process_type(p_process_type)
	instance.set_start_idx(p_start_idx)
	instance.set_end_idx(p_end_idx)
	instance.set_fade_out(p_fade_out)
	instance.set_key_type(p_key_type)
	instance.set_instances_type(p_instances_type)
	instance.set_speech_bubbles(p_speech_bubbles)
	
	_a_threads[p_key] = instance
	
	return instance

func _update_threads_vox(p_instance: FWDialogueSystemThread, p_process_type: String) -> void:
	if p_process_type == &"Main":
		# Tell all other threads to mute vox
		for child: FWDialogueSystemThread in _a_Threads.get_children():
			child.set_play_vox(false)
	
	elif p_process_type == &"Sub" || p_process_type == &"Manual":
		# Only play vox if there is no vox playback already
		for child: FWDialogueSystemThread in _a_Threads.get_children():
			if child.get_play_vox():
				p_instance.set_play_vox.call_deferred(false)
				break

func set_dialogue_process_mode(p_key: StringName, p_process_mode: ProcessMode) -> void:
	var instance: FWDialogueSystemThread = _a_threads[p_key]
	instance.set_process_mode_(p_process_mode)

func set_dialogue_layer(p_key: StringName, p_layer: int) -> void:
	var instance: FWDialogueSystemThread = _a_threads[p_key]
	instance.set_layer(p_layer)

func set_dialogue_completed_cb(p_key: StringName, p_completed_cb: Callable) -> void:
	var instance: FWDialogueSystemThread = _a_threads[p_key]
	instance.set_completed_cb(p_completed_cb)

func set_dialogue_choice_selected_cb(p_key: StringName, p_choice_selected_cb: Callable) -> void:
	var instance: FWDialogueSystemThread = _a_threads[p_key]
	instance.set_choice_selected_cb(p_choice_selected_cb)

func get_save_data(p_location: StringName, p_for_file: bool) -> Dictionary:
	_a_save_data[p_location] = {}
	var data: Dictionary = _a_save_data[p_location]
	
	data[&"Main_Active"] = _a_main_active
	data[&"Threads"] = []
	for child: FWDialogueSystemThread in _a_Threads.get_children():
		var save_data: Dictionary = child.get_save_data()
		data[&"Threads"].push_back(save_data)
		
		if !p_for_file:
			child.queue_free()
	
	return _a_save_data

func load_file_data(p_data: Dictionary) -> void:
	_a_save_data = p_data

func load_data(p_location: StringName) -> void:
	if !_a_save_data.has(p_location):
		return
	
	var save_data: Dictionary = _a_save_data[p_location]
	_a_main_active = save_data[&"Main_Active"]
	
	for args: Dictionary in save_data[&"Threads"]:
		var key_type: StringName = args[&"Key_Type"]
		var key: StringName = args[&"Key"]
		var process_type: StringName = args[&"Process_Type"]
		var idx: int = args[&"Idx"]
		var start_idx: int = args[&"Start_Idx"]
		var end_idx: int = args[&"End_Idx"]
		var fade_out: bool = args[&"Fade_Out"]
		var caller_path: NodePath = args[&"Caller_Path"]
		var caller: Node = get_node_or_null(caller_path)
		var completed_cb_object_path: NodePath = args[&"Completed_CB"][&"Object_Path"]
		var completed_cb_object: Node = get_node_or_null(completed_cb_object_path)
		var completed_cb: Callable = Callable()
		if completed_cb_object != null:
			var completed_cb_name: StringName = args[&"Completed_CB"][&"Name"]
			completed_cb = Callable(completed_cb_object, completed_cb_name)
		var choice_selected_cb_object_path: NodePath = args[&"Choice_Selected_CB"][&"Object_Path"]
		var choice_selected_cb_object: Node = get_node_or_null(choice_selected_cb_object_path)
		var choice_selected_cb: Callable = Callable()
		if choice_selected_cb_object != null:
			var choice_selected_cb_name: StringName = args[&"Choice_Selected_CB"][&"Name"]
			choice_selected_cb = Callable(choice_selected_cb_object, choice_selected_cb_name)
		#var instances_type = args["Instances_Type"]
		#var speech_bubbles = args["Speech_Bubbles"]
		
		var instance: FWDialogueSystemThread = _instantiate_thread(key, caller, process_type, start_idx,
										   						   end_idx, fade_out, key_type, &"Key")
		instance.set_idx(idx)
		_update_threads_vox(instance, process_type)
		instance.set_process_mode_.call_deferred(args[&"Process_Mode"])
		instance.set_layer.call_deferred(args[&"Layer"])
		instance.set_completed_cb(completed_cb)
		instance.set_choice_selected_cb(choice_selected_cb)
		
		_a_Threads.add_child(instance)

func _on_Thread_completed(p_instance: FWDialogueSystemThread) -> void:
	_a_Threads.remove_child(p_instance)
	
	var key: StringName = p_instance.get_key()
	var process_type: StringName = p_instance.get_process_type()
	if process_type == &"Main":
		# Give vox playback to latest main,
		# if there is none choose latest non-main
		var latest_main: FWDialogueSystemThread = null
		var latest_non_main: FWDialogueSystemThread = null
		var children: Array[Node] = _a_Threads.get_children()
		for i: int in range(children.size() - 1, -1, -1):
			var child: FWDialogueSystemThread = children[i]
			var child_process_type: StringName = child.get_process_type()
			if latest_main == null && child_process_type == &"Main":
				latest_main = child
			if latest_non_main == null && child_process_type != &"Main":
				latest_non_main = child
			if latest_main != null && latest_non_main != null:
				break
		
		if latest_main == null:
			if latest_non_main != null:
				latest_non_main.set_play_vox(true)
			
			main_completed.emit()
			_a_main_active = false
		else:
			latest_main.set_play_vox(true)
	
	elif process_type == &"Sub" || process_type == &"Manual":
		# If there is no main active latest non-main needs vox playback
		var children: Array[Node] = _a_Threads.get_children()
		if !_a_main_active:
			for i: int in range(children.size() - 1, -1, -1):
				var child: FWDialogueSystemThread = children[i]
				if child.get_process_type() != &"Main":
					child.set_play_vox(true)
					break
	
	_a_threads.erase(key)
	
	var completed_cb: Callable = p_instance.get_completed_cb()
	if completed_cb.is_valid():
		completed_cb.call(key)
