extends DebugValueSelect
class_name DebugItemSelect

signal selected()

@onready var _a_Select: TextureButton = get_node("Select")
@onready var _a_Item_Select: DebugItemSelectMenu = get_node("Canvas/Item_Select")

var _a_key: StringName
var _a_stack: int
var _a_image: Texture2D = null

func _ready() -> void:
	super()
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Item_Select.select_pressed.connect(_on_Item_Select_select_pressed)

func get_key() -> StringName:
	return _a_key

func get_stack_() -> int:
	return _a_stack

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_key
	data[&"Stack"] = _a_stack
	var image_path: String = ""
	if _a_image != null:
		image_path = _a_image.get_path()
	data[&"Image_Path"] = image_path
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	
	_a_key = p_data[&"Value"]
	_a_stack = p_data[&"Stack"]
	var image_path: String = p_data[&"Image_Path"]
	if !image_path.is_empty():
		_a_image = load(image_path)
		_a_Select.set_texture_normal(_a_image)

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Select.set_disabled(p_toggled)

func _on_Select_pressed() -> void:
	_a_Item_Select.open(_a_key)

func _on_Item_Select_select_pressed(p_key: StringName, p_stack: int, p_image: Texture2D) -> void:
	_a_Select.set_texture_normal(p_image)
	_a_key = p_key
	_a_stack = p_stack
	_a_image = p_image
	selected.emit()
