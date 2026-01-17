extends DebugEntryListEntry
class_name DebugEntryListChoiceEntry

@onready var _a_Loc_ID: DebugLocIDSelect = get_node("HBox/VBox/Options/Loc_ID")
@onready var _a_Value_Heading: Label = get_node("HBox/VBox/Options/Value/Heading")
@onready var _a_Value: DebugValueEdit = get_node("HBox/VBox/Options/Value/Value_Edit")
@onready var _a_Conditions_Heading: Label = get_node("HBox/VBox/Options/Conditions/Heading")
@onready var _a_Conditions: DebugExpressionEntryList = get_node("HBox/VBox/Options/Conditions/Entries")

func update_trans() -> void:
	_a_Value_Heading.set_text(tr(&"DEBUG_DIALOGUES_ATTRIBUTES_VALUE"))
	_a_Conditions_Heading.set_text(tr(&"DEBUG_DIALOGUES_ATTRIBUTES_CONDITIONS"))

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
