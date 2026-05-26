extends FWDebugValueSelectOptions
class_name FWDebugCommandEditCommandMatchChoicesPart

var _a_key_type: StringName # Map/Global
var _a_chapter: StringName
var _a_location: StringName
var _a_dialogue_key: StringName

func update_options() -> void:
	_clear_options()
	if _a_dialogue_key == &"":
		return
	
	var dialogues_data: Dictionary = Databases.get_global_map_data(&"Dialogues", _a_key_type, _a_chapter, _a_location)
	var i: int = 0
	for entry_key: StringName in dialogues_data[_a_dialogue_key][&"Data"]:
		var args: Dictionary = dialogues_data[_a_dialogue_key][&"Data"][entry_key]
		var type: StringName = args[&"Type"]
		var has_choice: bool = false
		match type:
			&"Text":
				var text_data: Dictionary = args[&"Data"][&"Text"]
				var choice_entries: Dictionary = text_data[&"Choice"][&"Entries"]
				has_choice = !choice_entries.is_empty()
			&"Choice":
				has_choice = true
		
		if has_choice:
			_a_Value.add_item(entry_key)
			_a_Value.set_item_metadata(i, entry_key)
			_a_option_idxs[entry_key] = i
			i += 1

func set_key_type(p_key_type: StringName) -> void:
	_a_key_type = p_key_type

func set_chapter(p_chapter: StringName) -> void:
	_a_chapter = p_chapter

func set_location(p_location: StringName) -> void:
	_a_location = p_location

func set_dialogue_key(p_dialogue_key: StringName) -> void:
	_a_dialogue_key = p_dialogue_key
