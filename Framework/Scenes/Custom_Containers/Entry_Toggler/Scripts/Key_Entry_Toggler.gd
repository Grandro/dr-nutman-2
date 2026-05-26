extends FWEntryToggler
class_name FWKeyEntryToggler

var _a_entries: Dictionary[StringName, FWEntryTogglerKeyEntry] = {} # Match key to instance

func instantiate_entry_(p_select_text: String, p_texture: Texture2D, p_key: StringName) -> FWEntryTogglerKeyEntry:
	var instance: FWEntryTogglerKeyEntry = instantiate_entry(p_select_text, p_texture)
	instance.set_key(p_key)
	
	_a_entries[p_key] = instance
	
	return instance

func toggle(p_key: StringName) -> void:
	var instance: FWEntryTogglerKeyEntry = _a_entries[p_key]
	_toggle(instance)
