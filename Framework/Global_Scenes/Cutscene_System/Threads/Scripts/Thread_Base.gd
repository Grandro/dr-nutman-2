extends Node
class_name FWCutsceneThreadBase

signal completed()

var _a_curr_scene: Node
var _a_command: StringName
var _a_args: Dictionary
var _a_skip: bool # Skip this command?
var _a_emitted_completed: bool = false # Only emit completed once
var _a_loads_data: bool

var _a_object: Node # Object instance if used by command
var _a_comp: Node # Comp of _a_object if used by command

# Revert properties when this thread is loaded from data
# (Because it was mid-execution on save)
var _a_revert_on_load: Dictionary = {} # Match instance key to {Property: Value}

func _ready() -> void:
	tree_exiting.connect(_on_tree_exiting)

func skip() -> void:
	pass

func _process_command() -> void:
	if _a_skip:
		skip()

func _emit_completed() -> void:
	if !_a_emitted_completed:
		_a_emitted_completed = true
		completed.emit()

func _add_revert_property(p_instance: Node, p_object_key: StringName, p_comp_key: StringName, p_property: StringName) -> void:
	if !_a_revert_on_load.has(p_object_key):
		_a_revert_on_load[p_object_key] = {}
	if !_a_revert_on_load[p_object_key].has(p_comp_key):
		_a_revert_on_load[p_object_key][p_comp_key] = {}
	var value: Variant = p_instance.get(p_property)
	_a_revert_on_load[p_object_key][p_comp_key][p_property] = value

func set_curr_scene(p_curr_scene: Node) -> void:
	_a_curr_scene = p_curr_scene

func set_command(p_command: StringName) -> void:
	_a_command = p_command

func get_command() -> StringName:
	return _a_command

func set_args(p_args: Dictionary) -> void:
	_a_args = p_args

func set_skip(p_skip: bool) -> void:
	_a_skip = p_skip

func set_loads_data(p_loads_data: bool) -> void:
	_a_loads_data = p_loads_data

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Command"] = _a_command
	data[&"Emitted_Completed"] = _a_emitted_completed
	data[&"Revert"] = {}
	data[&"Revert"][&"On_Load"] = _a_revert_on_load
	data[&"Process_Mode"] = get_process_mode()
	data[&"Args"] = {}
	
	return data

func load_data(p_data: Dictionary) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var on_load_args: Dictionary = p_data[&"Revert"][&"On_Load"]
	for object_key: StringName in on_load_args:
		var object: Node = global_si.get_object(object_key)
		for comp_key: StringName in on_load_args[object_key]:
			var comp: Node = object.comph().get_comp(comp_key)
			for property: StringName in on_load_args[object_key][comp_key]:
				var value: Variant = on_load_args[object_key][comp_key][property]
				comp.set(property, value)
	
	_a_emitted_completed = p_data[&"Emitted_Completed"]
	set_process_mode(p_data[&"Process_Mode"])

func _on_tree_exiting() -> void:
	if is_instance_valid(_a_object):
		_a_object.comph().call_comp("Cutscene", &"decrease_in_cutscene")
