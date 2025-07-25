extends MarginContainer

signal selected()

@onready var _a_Color = get_node("Color")
@onready var _a_Select = get_node("Select")
@onready var _a_Border = get_node("Border")
@onready var _a_Fav = get_node("Fav")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Border.hide()
	_a_Fav.hide()

func select():
	_a_Border.show()

func deselect():
	_a_Border.hide()

func show_fav():
	_a_Fav.show()

func set_color(p_color):
	_a_Color.set_color(p_color)

func get_color():
	return _a_Color.get_color()

func _on_Select_pressed():
	selected.emit()
