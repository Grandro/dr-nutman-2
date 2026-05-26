extends Node
class_name FWCompReference

var _a_key: StringName

func init(p_entities: Array[Node]) -> void:
	_a_key = p_entities[-1].get_name()

func get_key() -> StringName:
	return _a_key

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
