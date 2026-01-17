extends MarginContainer
class_name NutOSContentDesktopAppSettingsMenuBackgroundEntry

signal selected()

@onready var _a_Image: TextureRect = get_node("Image")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_Border: TextureRect = get_node("Border")

var _a_key: StringName

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Border.hide()

func select() -> void:
	_a_Border.show()

func deselect() -> void:
	_a_Border.hide()

func get_texture() -> Texture2D:
	return _a_Image.get_texture()

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func _on_Select_pressed() -> void:
	selected.emit()
