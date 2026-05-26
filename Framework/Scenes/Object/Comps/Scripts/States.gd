extends Node
class_name FWCompStates

signal state_tmp_changed(p_state_tmp: StringName)

@export var _e_states: Array[StringName] = []
@export var _e_state: StringName = &""

var _a_state_tmp: StringName = _e_state

func init(_p_entities: Array[Node]) -> void:
	set_state_tmp(_e_state)

func revert_state_tmp() -> void:
	set_state_tmp(_e_state)

func get_states() -> Array[StringName]:
	return _e_states

func set_state(p_state: StringName) -> void:
	_e_state = p_state
	set_state_tmp(p_state)

func get_state() -> StringName:
	return _e_state

func has_state(p_state: StringName) -> bool:
	return _e_states.has(p_state)

func set_state_tmp(p_state_tmp: StringName) -> void:
	_a_state_tmp = p_state_tmp
	state_tmp_changed.emit(p_state_tmp)

func get_state_tmp() -> StringName:
	return _a_state_tmp

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"State"] = get_state()
	data[&"State_Tmp"] = get_state_tmp()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_state(p_data[&"State"])
	set_state_tmp(p_data[&"State_Tmp"])

func load_data_init() -> void:
	pass
