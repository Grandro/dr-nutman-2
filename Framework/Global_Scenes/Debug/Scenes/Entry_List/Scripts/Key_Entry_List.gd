extends FWDebugEntryList
class_name FWDebugKeyEntryList

signal entry_key_changed(p_key: StringName, p_instance: FWDebugEntryListKeyEntry)

func instantiate_entry_(p_key: StringName) -> FWDebugEntryListKeyEntry:
	var instance: FWDebugEntryListKeyEntry = instantiate_entry(p_key)
	instance.key_changed.connect(_on_Entry_key_changed.bind(instance))
	instance.set_key(p_key)
	
	return instance

func get_entries_keys() -> Array[StringName]:
	var keys: Array[StringName] = []
	var size_: int = _a_VBox.get_child_count()
	keys.resize(size_)
	for i: int in size_:
		var child: FWDebugEntryListKeyEntry = _a_VBox.get_child(i)
		var key: StringName = child.get_key()
		keys[i] = key
	
	return keys

func _on_Entry_key_changed(p_key: StringName, p_instance: FWDebugEntryListKeyEntry) -> void:
	p_instance.set_change_key_text("")
	entry_key_changed.emit(p_key, p_instance)
