extends MarginContainer
class_name NutOSContentStartMenuApp

signal select_pressed()

var _a_Highlighted: StyleBoxFlat = preload("uid://b4ehs25kus1so")
var _a_Normal: StyleBoxEmpty = preload("uid://de1arcaynwihv")

@onready var _a_Select: Button = get_node("Select")
@onready var _a_Name: Label = get_node("HBox/Name")

var _a_key: StringName

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)

func set_highlighted(p_highlighted: bool) -> void:
	if p_highlighted:
		_a_Select.set(&"theme_override_styles/normal", _a_Highlighted)
	else:
		_a_Select.set(&"theme_override_styles/normal", _a_Normal)

func get_name_() -> String:
	return tr(_a_Name.get_text())

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key

func _on_Select_pressed() -> void:
	select_pressed.emit()
