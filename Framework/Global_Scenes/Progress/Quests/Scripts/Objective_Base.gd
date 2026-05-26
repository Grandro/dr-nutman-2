extends Node
class_name FWProgressQuestObjectiveBase

signal progressed()
signal completed()

@export var _e_data: FWObjectiveData = null

var _a_active: bool = true
var _a_value: Variant = null

func _ready() -> void:
	if !_a_active:
		return
	
	_update_progress()

func manual_progress() -> void:
	pass

func _update_progress() -> void:
	pass

func _completed() -> void:
	_a_active = false
	completed.emit()

func get_data() -> FWObjectiveData:
	return _e_data

func get_value() -> Variant:
	return _a_value

func get_target_value() -> Variant:
	return _e_data.get_target_value()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Active"] = _a_active
	data[&"Value"] = _a_value
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	_a_active = p_data[&"Active"]
	_a_value = p_data[&"Value"]

func load_data_init() -> void:
	pass
