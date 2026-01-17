extends MarginContainer
class_name NutOSContentDesktopAppSettingsOptionEntry

signal selected()

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Icon: TextureRect = get_node("Margin/HBox/Icon")
@onready var _a_Heading: Label = get_node("Margin/HBox/VBox/Heading")
@onready var _a_Desc: Label = get_node("Margin/HBox/VBox/Desc")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)

func set_icon(p_texture: Texture2D) -> void:
	_a_Icon.set_texture(p_texture)

func set_heading(p_text: String) -> void:
	_a_Heading.set_text(p_text)

func set_desc(p_text: String) -> void:
	_a_Desc.set_text(p_text)

func _on_Select_pressed() -> void:
	selected.emit()
