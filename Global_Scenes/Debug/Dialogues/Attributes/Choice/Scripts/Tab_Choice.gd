extends DebugDialoguesAttributesTabBase
class_name DebugDialoguesAttributesChoiceTabChoice

@onready var _a_Entries: DebugChoiceEntryList = get_node("Margin/HSplit/Left/Entries")
@onready var _a_Name: DebugLocIDSelect = get_node("Margin/HSplit/Left/Name")

func open(p_data: Dictionary) -> void:
	_a_Entries.load_data(p_data[&"Entries"])
	_a_Name.load_data(p_data[&"Name"])

func open_init() -> void:
	_a_Entries.clear_entries()
	_a_Name.load_data_init()

func set_keys_type(p_keys_type: StringName) -> void:
	_a_Entries.set_keys_type(p_keys_type)
	_a_Name.set_loc_id_type(p_keys_type)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Entries"] = _a_Entries.get_save_data()
	data[&"Name"] = _a_Name.get_save_data()
	
	return data
