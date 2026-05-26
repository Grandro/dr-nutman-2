extends MarginContainer
class_name FWEntryTogglerEntry

signal select_toggled(p_toggled: bool)

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Texture: TextureRect = get_node("Margin/Texture")

func _ready() -> void:
	_a_Select.toggled.connect(_on_Select_toggled)

func set_select_text(p_text: String) -> void:
	_a_Select.set_text(p_text)

func set_select_disabled(p_disabled: bool) -> void:
	_a_Select.set_disabled(p_disabled)

func set_select_pressed(p_pressed: bool) -> void:
	_a_Select.set_pressed(p_pressed)

func set_select_tooltip_text(p_tooltip_text: String) -> void:
	_a_Select.set_tooltip_text(p_tooltip_text)

func set_texture(p_texture: Texture2D) -> void:
	_a_Texture.set_texture(p_texture)

func _on_Select_toggled(p_pressed: bool) -> void:
	select_toggled.emit(p_pressed)
