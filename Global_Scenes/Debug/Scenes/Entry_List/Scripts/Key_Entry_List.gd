extends DebugEntryList
class_name DebugKeyEntryList

signal entry_key_changed(p_key: StringName, p_instance: DebugEntryListKeyEntry)

func instantiate_entry_(p_key: StringName) -> DebugEntryListKeyEntry:
	var instance: DebugEntryListKeyEntry = instantiate_entry(p_key)
	instance.key_changed.connect(_on_Entry_key_changed.bind(instance))
	instance.set_key(p_key)
	
	return instance

func get_entries_keys() -> Array[StringName]:
	var keys: Array[StringName] = []
	for child: DebugEntryListKeyEntry in _a_VBox.get_children():
		var key: StringName = child.get_key()
		keys.push_back(key)
	
	return keys

func _on_Entry_key_changed(p_key: StringName, p_instance: DebugEntryListKeyEntry) -> void:
	p_instance.set_change_key_text("")
	entry_key_changed.emit(p_key, p_instance)
