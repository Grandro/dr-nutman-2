extends FWDebugDialoguesAttributesTabBase
class_name FWDebugDialoguesAttributesTextTabPos

const _a_POS_LOC_ID: String = "FW_POS_%s"
const _a_NAME_TYPES: Array[StringName] = [&"Top", &"Bottom"]

@onready var _a_Pos_Type: OptionButton = get_node("Margin/HSplit/Left/Pos/Type/Options")
@onready var _a_Pos_Custom_VBox: VBoxContainer = get_node("Margin/HSplit/Left/Pos/Custom")
@onready var _a_Pos_Custom: FWDebugValueEdit = get_node("Margin/HSplit/Left/Pos/Custom/Value")
@onready var _a_Pos_Name_Type: OptionButton = get_node("Margin/HSplit/Left/Pos/Name_Type/Options")
@onready var _a_Pos_Small_Preview: FWDebugDialoguesAttributesTextSmallPreview = get_node("Margin/HSplit/Left/Pos/Small_Preview")
@onready var _a_Name: FWDebugLocIDSelect = get_node("Margin/HSplit/Left/Name")
@onready var _a_Show_Arrow: CheckBox = get_node("Margin/HSplit/Left/Show_Arrow/Value")

var _a_pos_type_idxs: Dictionary[StringName, int] = {} # Match pos_type to idx
var _a_pos_name_type_idxs: Dictionary[StringName, int] = {} # Match pos_name_type to idx

func _ready() -> void:
	_a_Pos_Type.item_selected.connect(_on_Pos_Type_item_selected)
	_a_Pos_Custom.value_changed.connect(_on_Pos_Custom_value_changed)
	_a_Pos_Name_Type.item_selected.connect(_on_Pos_Name_Type_item_selected)
	_a_Name.selected.connect(_on_Name_selected)
	_a_Show_Arrow.pressed.connect(_on_Show_Arrow_pressed)
	
	_create_pos_type_options()
	_create_pos_name_type_options()

func open(p_data: Dictionary) -> void:
	var pos_type: StringName = p_data[&"Pos"][&"Type"]
	var idx: int = _a_pos_type_idxs[pos_type]
	_a_Pos_Type.select(idx)
	
	var pos_custom: Vector2 = p_data[&"Pos"][&"Custom"]
	_a_Pos_Custom.set_value(pos_custom)
	
	var pos_name_type: StringName = p_data[&"Pos"][&"Name_Type"]
	idx = _a_pos_name_type_idxs[pos_name_type]
	_a_Pos_Name_Type.select(idx)
	
	_a_Name.load_data(p_data[&"Name"])
	var name_loc_id: StringName = p_data[&"Name"][&"Loc_ID"]
	_a_Pos_Small_Preview.set_name_visible(name_loc_id != &"")
	_a_Show_Arrow.set_pressed(p_data[&"Show_Arrow"])
	
	_selected_type_changed()
	_custom_value_changed()
	_selected_name_type_changed()
	_selected_type_changed()

func open_init() -> void:
	_a_Pos_Type.select(0)
	_a_Pos_Custom.set_value(Vector2.ZERO)
	_a_Pos_Name_Type.select(0)
	_a_Name.load_data_init()
	_a_Show_Arrow.set_pressed(false)
	
	_selected_type_changed()
	_custom_value_changed()
	_selected_name_type_changed()
	_selected_type_changed()

func _create_pos_type_options() -> void:
	var layouts: Array[StringName] = Global.get_layouts()
	var layouts_size: int = layouts.size()
	for i: int in layouts_size:
		var type: StringName = layouts[i]
		var text: String = tr(_a_POS_LOC_ID % type.to_upper())
		_a_pos_type_idxs[type] = i
		_a_Pos_Type.add_item(text)
		_a_Pos_Type.set_item_metadata(i, type)
	
	_a_pos_type_idxs[&"Custom"] = layouts_size
	_a_Pos_Type.add_item(tr(&"CUSTOM"))
	_a_Pos_Type.set_item_metadata(layouts_size, &"Custom")

func _create_pos_name_type_options() -> void:
	for i: int in _a_NAME_TYPES.size():
		var name_type: StringName = _a_NAME_TYPES[i]
		var text: String = tr(_a_POS_LOC_ID % name_type.to_upper())
		_a_pos_name_type_idxs[name_type] = i
		_a_Pos_Name_Type.add_item(text)
		_a_Pos_Name_Type.set_item_metadata(i, name_type)

func _selected_type_changed() -> void:
	var type: StringName = _a_Pos_Type.get_selected_metadata()
	_a_Pos_Custom_VBox.set_visible(type == &"Custom")
	_a_Pos_Small_Preview.set_type(type)
	_a_Pos_Small_Preview.update()

func _custom_value_changed() -> void:
	var custom: Vector2 = _a_Pos_Custom.get_value() / 10.0
	_a_Pos_Small_Preview.set_custom(custom)
	_a_Pos_Small_Preview.update()

func _selected_name_type_changed() -> void:
	var name_type: StringName = _a_Pos_Name_Type.get_selected_metadata()
	_a_Pos_Small_Preview.set_name_type(name_type)
	_a_Pos_Small_Preview.update()

func set_keys_type(p_keys_type: StringName) -> void:
	_a_Name.set_loc_id_type(p_keys_type)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Pos"] = {}
	data[&"Pos"][&"Type"] = _a_Pos_Type.get_selected_metadata()
	data[&"Pos"][&"Custom"] = _a_Pos_Custom.get_value()
	data[&"Pos"][&"Name_Type"] = _a_Pos_Name_Type.get_selected_metadata()
	data[&"Name"] = _a_Name.get_save_data()
	data[&"Show_Arrow"] = _a_Show_Arrow.is_pressed()
	
	return data

func _on_Pos_Type_item_selected(_p_idx: int) -> void:
	_selected_type_changed()

func _on_Pos_Custom_value_changed(_p_value: Vector2) -> void:
	_custom_value_changed()

func _on_Pos_Name_Type_item_selected(_p_idx: int) -> void:
	_selected_name_type_changed()

func _on_Name_selected() -> void:
	_a_Pos_Small_Preview.set_name_visible(true)

func _on_Show_Arrow_pressed() -> void:
	var show_arrow: bool = _a_Show_Arrow.is_pressed()
	_a_Pos_Small_Preview.set_arrow_visible(show_arrow)
	_a_Pos_Small_Preview.update()
