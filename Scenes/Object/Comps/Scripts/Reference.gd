extends Node
class_name CompReference

var _a_key: StringName

func init(p_entity: Node) -> void:
	_a_key = p_entity.get_name()

func get_key() -> StringName:
	return _a_key

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
