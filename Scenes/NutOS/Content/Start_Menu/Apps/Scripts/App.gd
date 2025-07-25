extends MarginContainer

signal select_pressed()

var _a_Highlighted = preload("res://Scenes/NutOS/Content/Start_Menu/Apps/Resources/Highlighted.tres")
var _a_Normal = preload("res://Scenes/NutOS/Content/Start_Menu/Apps/Resources/Normal.tres")

@onready var _a_Select = get_node("Select")
@onready var _a_Name = get_node("HBox/Name")

var _a_key = ""

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)

func set_highlighted(p_highlighted):
	if p_highlighted:
		_a_Select.set("theme_override_styles/normal", _a_Highlighted)
	else:
		_a_Select.set("theme_override_styles/normal", _a_Normal)

func get_name_():
	return tr(_a_Name.get_text())

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func _on_Select_pressed():
	select_pressed.emit()
