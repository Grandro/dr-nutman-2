extends DebugEntryList
class_name DebugChoiceEntryList

var _a_keys_type: StringName # Map/Global

func instantiate_entry_(p_loc_id: StringName, p_value: Variant, p_name: String = "") -> DebugEntryListChoiceEntry:
	var instance: DebugEntryListChoiceEntry = instantiate_entry(p_name)
	if !_e_enumerate:
		var idx: int = _a_VBox.get_child_count()
		instance.set_select_text.call_deferred(str(idx))
	instance.set_loc_id_type.call_deferred(_a_keys_type)
	instance.set_loc_id.call_deferred(p_loc_id)
	instance.set_value.call_deferred(p_value)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> DebugEntryListChoiceEntry:
	var loc_id: StringName = p_data[&"Loc_ID"][&"Loc_ID"]
	var value: Variant = p_data[&"Value"]
	var name_: String = p_data[&"Name"]
	var instance = instantiate_entry_(loc_id, value, name_)
	
	return instance

func set_keys_type(p_keys_type: StringName) -> void:
	_a_keys_type = p_keys_type

func _on_Add_pressed() -> void:
	var instance = instantiate_entry_(&"", "")
	add_entry(instance)
