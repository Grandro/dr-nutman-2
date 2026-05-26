extends Camera2D
class_name FWCompCamera2D

signal made_current()

func init(_p_entities: Array[Node]) -> void:
	pass

func make_current_() -> void:
	make_current()
	made_current.emit()

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
