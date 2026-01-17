extends MarginContainer
class_name NutOSContentDesktopAppSettingsMenuKeyboardColorEntry

signal selected()

@onready var _a_Color: ColorRect = get_node("Color")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_Border: TextureRect = get_node("Border")
@onready var _a_Fav: CenterContainer = get_node("Fav")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Border.hide()
	_a_Fav.hide()

func select() -> void:
	_a_Border.show()

func deselect() -> void:
	_a_Border.hide()

func show_fav() -> void:
	_a_Fav.show()

func set_color(p_color: Color) -> void:
	_a_Color.set_color(p_color)

func get_color() -> Color:
	return _a_Color.get_color()

func _on_Select_pressed() -> void:
	selected.emit()
