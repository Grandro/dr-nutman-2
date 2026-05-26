extends FWDebugEntryList
class_name FWDebugValueEditEntryList

@export var _e_type_editable: bool = false
@export var _e_value_editable: bool = false

func instantiate_entry_(p_value: Variant = "", p_name: String = "") -> FWDebugEntryListValueEditEntry:
	var instance: FWDebugEntryListValueEditEntry = instantiate_entry(p_name)
	instance.set_type_editable.call_deferred(_e_type_editable)
	instance.set_value_editable.call_deferred(_e_value_editable)
	instance.set_value.call_deferred(p_value)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> FWDebugEntryListValueEditEntry:
	var value: Variant = p_data[&"Value"]
	var name_: String = p_data[&"Name"]
	var instance = instantiate_entry_(value, name_)
	
	return instance

func set_type_editable(p_type_editable: bool) -> void:
	_e_type_editable = p_type_editable
	for child: FWDebugEntryListValueEditEntry in _a_VBox.get_children():
		child.set_type_editable(p_type_editable)

func set_value_editable(p_value_editable: bool) -> void:
	_e_value_editable = p_value_editable
	for child: FWDebugEntryListValueEditEntry in _a_VBox.get_children():
		child.set_value_editable(p_value_editable)

func _on_Add_pressed() -> void:
	var instance: FWDebugEntryListValueEditEntry = instantiate_entry_()
	add_entry(instance)
