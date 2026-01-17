extends MarginContainer
class_name NutOSContentDesktopAppSettingsMenuBase

signal return_pressed()
signal option_selected(p_key: StringName, p_option: StringName, p_texture: Texture2D)

@onready var _a_Return: TextureButton = get_node("VBox/Return")

var _a_key: StringName

func _ready() -> void:
	_a_Return.pressed.connect(_on_Return_pressed)

func open(_p_data: Dictionary) -> void:
	pass

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func get_save_data() -> Dictionary:
	return {}

func _on_Return_pressed() -> void:
	return_pressed.emit()
