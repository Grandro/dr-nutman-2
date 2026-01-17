extends Control
class_name ItemEntryBase

@onready var _a_Image: TextureRect = get_node("VBox/Margin/Image")

var _a_key: StringName = &""

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func set_texture(p_texture: Texture2D) -> void:
	_a_Image.set_texture(p_texture)

func get_texture() -> Texture2D:
	return _a_Image.get_texture()
