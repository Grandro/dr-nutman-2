extends DebugEntryList
class_name DebugActionEntryList

signal entry_preview_pressed(p_cutscene_data: Array[Dictionary])
signal entry_option_test_selected(p_cutscene_data: Array[Dictionary], p_skip_idxs: Array[int])
signal entry_selectable_focus_entered(p_instance: DebugEntryListActionEntry)

func instantiate_entry_(p_data: Array[Dictionary] = [], p_name: String = "") -> DebugEntryListActionEntry:
	var instance: DebugEntryListActionEntry = instantiate_entry(p_name)
	instance.preview_pressed.connect(_on_Entry_preview_pressed)
	instance.option_test_selected.connect(_on_Entry_option_test_selected)
	instance.selectable_focus_entered.connect(_on_Entry_selectable_focus_entered.bind(instance))
	instance.update_entries.call_deferred(p_data)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> DebugEntryListActionEntry:
	var data: Array[Dictionary]; data.assign(p_data[&"Editor"])
	var name_: String = p_data[&"Name"]
	var instance: DebugEntryListActionEntry = instantiate_entry_(data, name_)
	
	return instance

func _on_Entry_preview_pressed(p_cutscene_data: Array[Dictionary]) -> void:
	entry_preview_pressed.emit(p_cutscene_data)

func _on_Entry_option_test_selected(p_cutscene_data: Array[Dictionary], p_skip_idxs: Array[int]) -> void:
	entry_option_test_selected.emit(p_cutscene_data, p_skip_idxs)

func _on_Entry_selectable_focus_entered(p_instance: DebugEntryListActionEntry) -> void:
	entry_selectable_focus_entered.emit(p_instance)

func _on_Add_pressed() -> void:
	var instance: DebugEntryListActionEntry = instantiate_entry_()
	add_entry(instance)
