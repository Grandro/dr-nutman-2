extends Node3D
class_name ObjectSetupComputer

@export var _e_light_1_on_color: Color = Color.CORNFLOWER_BLUE
@export var _e_light_2_on_color: Color = Color.LAWN_GREEN
@export var _e_light_off_color: Color = Color(0.3, 0.3, 0.3)

@onready var _a_Light_1: Sprite3D = get_node("Light_1")
@onready var _a_Light_2: Sprite3D = get_node("Light_2")

func turn_on() -> void:
	_a_Light_1.set_modulate(_e_light_1_on_color)
	_a_Light_2.set_modulate(_e_light_2_on_color)

func turn_off() -> void:
	_a_Light_1.set_modulate(_e_light_off_color)
	_a_Light_2.set_modulate(_e_light_off_color)
