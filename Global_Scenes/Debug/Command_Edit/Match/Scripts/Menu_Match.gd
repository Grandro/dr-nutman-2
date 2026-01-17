extends DebugCommandEditMenuBase
class_name DebugCommandEditMenuMatch

signal branches_values_changed()

@export var _e_branches_editable: bool = true

var _a_branches_values: Array = []

func is_branches_editable() -> bool:
	return _e_branches_editable

func set_branches_values(p_branches_values: Array) -> void:
	_a_branches_values = p_branches_values

func get_branches_values() -> Array:
	return _a_branches_values

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Branches_Values"] = _a_branches_values
	
	return data

func _load_data(p_data: Dictionary) -> void:
	_a_branches_values = p_data[&"Branches_Values"]
