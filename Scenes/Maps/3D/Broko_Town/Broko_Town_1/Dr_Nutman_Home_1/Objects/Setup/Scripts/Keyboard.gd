extends Node3D
class_name ObjectSetupKeyboard

@export var _e_off_color: Color = Color(0.3, 0.3, 0.3)

@onready var _a_Keys_LED: Node3D = get_node("Keys_LED")

var _a_active: bool = false
var _a_static_color: Color = _e_off_color
var _a_copy_fav_color: bool = true

func _ready() -> void:
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	_a_static_color = Global_Data.get_fav_color()

func turn_on() -> void:
	change_static_color(_a_static_color)
	_a_active = true

func turn_off() -> void:
	change_static_color(_e_off_color)
	_a_active = false

func change_static_color(p_color: Color) -> void:
	for child: Node3D in _a_Keys_LED.get_children():
		child.set_modulate(p_color)

func set_static_color(p_color: Color, p_is_fav_color: bool) -> void:
	change_static_color(p_color)
	
	_a_static_color = p_color
	_a_copy_fav_color = p_is_fav_color

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Active"] = _a_active
	data[&"Static_Color"] = _a_static_color
	data[&"Copy_Fav_Color"] = _a_copy_fav_color
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_active = p_data[&"Active"]
	_a_static_color = p_data[&"Static_Color"]
	_a_copy_fav_color = p_data[&"Copy_Fav_Color"]
	
	if _a_active:
		change_static_color(_a_static_color)

func _on_Global_Data_fav_color_changed(p_color: Color) -> void:
	if _a_copy_fav_color:
		if _a_active:
			change_static_color(p_color)
		_a_static_color = p_color
