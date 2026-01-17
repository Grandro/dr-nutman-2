extends MarginContainer
class_name DebugCommandEditMenuBase

@export var _e_key: StringName = &""

func get_key() -> StringName:
	return _e_key

func load_data(p_data: Dictionary) -> void:
	if p_data.is_empty():
		_load_data_init()
	else:
		_load_data(p_data)

func _load_data_init() -> void:
	pass

func _load_data(_p_data: Dictionary) -> void:
	pass
