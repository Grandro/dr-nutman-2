extends FWDebugEntryListEntry
class_name FWDebugEntryListChoiceEntry

@onready var _a_Loc_ID: FWDebugLocIDSelect = get_node("HBox/VBox/Options/Loc_ID")
@onready var _a_Value: FWDebugValueEdit = get_node("HBox/VBox/Options/Value/Value_Edit")
@onready var _a_Conditions: FWDebugExpressionEntryList = get_node("HBox/VBox/Options/Conditions/Entries")

func set_loc_id_type(p_loc_id_type: StringName) -> void:
	_a_Loc_ID.set_loc_id_type(p_loc_id_type)

func set_loc_id(p_loc_id: StringName) -> void:
	_a_Loc_ID.set_loc_id(p_loc_id)

func set_value(p_value: Variant) -> void:
	_a_Value.set_value(p_value)

func get_value() -> Variant:
	return _a_Value.get_value()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Loc_ID"] = _a_Loc_ID.get_save_data()
	data[&"Value"] = _a_Value.get_value()
	data[&"Conditions"] = _a_Conditions.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Conditions.load_data(p_data[&"Conditions"])
