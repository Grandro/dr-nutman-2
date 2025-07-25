extends MarginContainer

signal selected()

@onready var _a_Image = get_node("Image")
@onready var _a_Select = get_node("Select")
@onready var _a_Border = get_node("Border")

var _a_key = ""

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Border.hide()

func select():
	_a_Border.show()

func deselect():
	_a_Border.hide()

func get_texture():
	return _a_Image.get_texture()

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func _on_Select_pressed():
	selected.emit()
