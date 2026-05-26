extends Node
class_name FWCompOperate

signal to_disabled()
signal to_enabled()

var _a_disabled: int = 0 # 0 = enabled, >0 = disabled

func init(_p_entities: Array[Node]) -> void:
	pass

func disable() -> void:
	if _a_disabled == 0:
		to_disabled.emit()
	_a_disabled += 1

func enable() -> void:
	if _a_disabled == 1:
		to_enabled.emit()
	_a_disabled -= 1

func set_disabled(p_disabled: int) -> void:
	if _a_disabled == 0 && p_disabled != 0:
		to_disabled.emit()
	elif _a_disabled != 0 && p_disabled == 0:
		to_enabled.emit()
	
	_a_disabled = p_disabled

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Disabled"] = _a_disabled
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_disabled = p_data[&"Disabled"]
	if _a_disabled == 0:
		to_enabled.emit()
	else:
		to_disabled.emit()

func load_data_init() -> void:
	pass
