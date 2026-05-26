extends FWDebugDialoguesAttributesTabBase
class_name FWDebugDialoguesAttributesTabGeneral

@onready var _a_Text: FWDebugLocIDSelect = get_node("Margin/HSplit/Left/Text")

func open(p_data: Dictionary) -> void:
	_a_Text.load_data(p_data["Text"])

func open_init() -> void:
	_a_Text.load_data_init()

func set_keys_type(p_keys_type: StringName) -> void:
	_a_Text.set_loc_id_type(p_keys_type)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data["Text"] = _a_Text.get_save_data()
	
	return data
