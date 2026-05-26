extends FWDebugValueSelectOptions
class_name FWDebugCommandEditCommandShowDialogueKey

var _a_key_type: StringName

func update_options() -> void:
	_clear_options()
	
	var dialogues_data: Dictionary = Databases.get_global_map_data("Dialogues", _a_key_type)
	var keys: Array = dialogues_data.keys()
	for i: int in keys.size():
		var key: Variant = keys[i]
		_a_option_idxs[key] = i
		_a_Value.add_item(key)
		_a_Value.set_item_metadata(i, key)

func set_key_type(p_key_type: StringName) -> void:
	_a_key_type = p_key_type
