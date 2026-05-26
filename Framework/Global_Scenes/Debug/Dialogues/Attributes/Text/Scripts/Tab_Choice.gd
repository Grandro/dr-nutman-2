extends FWDebugDialoguesAttributesTabBase
class_name FWDebugDialoguesAttributesTextTabChoice

const _a_POS_LOC_ID: String = "FW_POS_%s"
const _a_POS_TYPES: Array[StringName] = [&"Left", &"Center", &"Right"]

@onready var _a_Pos: OptionButton = get_node("Margin/HSplit/Left/Pos/Options")
@onready var _a_Pos_Small_Preview: FWDebugDialoguesAttributesTextSmallPreview = get_node("Margin/HSplit/Left/Pos/Small_Preview")
@onready var _a_Entries: FWDebugChoiceEntryList = get_node("Margin/HSplit/Left/Entries")

var _a_pos_types_idxs: Dictionary[StringName, int] = {} # Match type to idx

func _ready() -> void:
	_a_Pos.item_selected.connect(_on_Pos_item_selected)
	
	_create_pos_types_options()
	
	_a_Pos_Small_Preview.set_name_type(&"Top")
	_a_Pos_Small_Preview.set_type(&"Center")
	_a_Pos_Small_Preview.set_choices_box_visible(true)

func open(p_data: Dictionary) -> void:
	var type: StringName = p_data[&"Pos"][&"Type"]
	var idx: int = _a_pos_types_idxs[type]
	_a_Pos.select(idx)
	_a_Pos_Small_Preview.set_choices_box_layout(type)
	
	_a_Entries.load_data(p_data[&"Entries"])

func open_init() -> void:
	_a_Pos.select(0)
	_a_Entries.clear_entries()

func _create_pos_types_options() -> void:
	for i: int in _a_POS_TYPES.size():
		var type: StringName = _a_POS_TYPES[i]
		var text: String = tr(_a_POS_LOC_ID % type.to_upper())
		_a_pos_types_idxs[type] = i
		_a_Pos.add_item(text)
		_a_Pos.set_item_metadata(i, type)

func set_keys_type(p_keys_type: StringName) -> void:
	_a_Entries.set_keys_type(p_keys_type)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Pos"] = {}
	data[&"Pos"][&"Type"] = _a_Pos.get_selected_metadata()
	data[&"Entries"] = _a_Entries.get_save_data()
	
	return data

func _on_Pos_item_selected(p_idx: int) -> void:
	var type: StringName = _a_Pos.get_item_metadata(p_idx)
	_a_Pos_Small_Preview.set_choices_box_layout(type)
