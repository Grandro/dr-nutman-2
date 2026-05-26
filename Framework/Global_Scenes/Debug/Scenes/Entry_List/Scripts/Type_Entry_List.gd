extends FWDebugEntryList
class_name FWDebugTypeEntryList

signal entry_type_changing()
signal entry_type_changed(p_instance: FWDebugEntryListTypeEntry)

@export var _e_types: Array[StringName] = []
@export var _e_default_value: Variant

func instantiate_entry_(p_type: StringName = &"", p_data: Dictionary[StringName, Variant] = {}, p_name: String = "") -> FWDebugEntryListTypeEntry:
	var instance: FWDebugEntryListTypeEntry = instantiate_entry(p_name)
	if p_data.is_empty():
		p_data = _get_empty_data()
	
	instance.type_changing.connect(_on_Entry_type_changing)
	instance.type_changed.connect(_on_Entry_type_changed.bind(instance))
	instance.set_data(p_data)
	instance.set_types.call_deferred(_e_types)
	if !p_type.is_empty():
		instance.select_type.call_deferred(p_type)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> FWDebugEntryListTypeEntry:
	var type: StringName = p_data[&"Type"]
	var data: Dictionary[StringName, Variant]; data.assign(p_data[&"Data"])
	var name_: String = p_data[&"Name"]
	var instance: FWDebugEntryListTypeEntry = instantiate_entry_(type, data, name_)
	
	return instance

func _get_empty_data() -> Dictionary[StringName, Variant]:
	var data: Dictionary[StringName, Variant] = {}
	for type: StringName in _e_types:
		data[type] = _e_default_value
	
	return data

func _on_Add_pressed() -> void:
	var instance: FWDebugEntryListTypeEntry = instantiate_entry_()
	add_entry(instance)

func _on_Entry_type_changing() -> void:
	entry_type_changing.emit()

func _on_Entry_type_changed(p_instance: FWDebugEntryListTypeEntry) -> void:
	entry_type_changed.emit(p_instance)
