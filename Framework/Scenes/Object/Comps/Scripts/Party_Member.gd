extends Node
class_name FWCompPartyMember

@export var _e_pm_key: StringName = &""

func init(_p_entities: Array[Node]) -> void:
	pass

func get_pm_key() -> StringName:
	return _e_pm_key

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
