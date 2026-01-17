extends ExtensionBase
class_name CompDisplayShared

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Frame"] = _a_entity.get_frame()
	data[&"Modulate"] = _a_entity.get_modulate()
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_entity.set_frame(p_data[&"Frame"])
	_a_entity.set_modulate(p_data[&"Modulate"])
