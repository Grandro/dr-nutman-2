extends FWDebugEntryListEntry
class_name FWDebugEntryListValueEditEntry

@onready var _a_Value: FWDebugValueEdit = get_node("HBox/VBox/Options/Value")

func set_value(p_value: Variant) -> void:
	_a_Value.set_value(p_value)

func get_value() -> Variant:
	return _a_Value.get_value()

func set_type_editable(p_type_editable: bool) -> void:
	_a_Value.set_type_editable(p_type_editable)

func set_value_editable(p_value_editable: bool) -> void:
	_a_Value.set_value_editable(p_value_editable)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = get_value()
	
	return data
