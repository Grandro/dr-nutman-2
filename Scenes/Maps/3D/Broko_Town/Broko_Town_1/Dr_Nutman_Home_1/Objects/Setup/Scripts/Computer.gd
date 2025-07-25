extends Node3D

@export var _e_light_1_on_color: Color = Color.CORNFLOWER_BLUE
@export var _e_light_2_on_color: Color = Color.LAWN_GREEN
@export var _e_light_off_color: Color = Color(0.3, 0.3, 0.3)

@onready var _a_Sprite_Light_1 = get_node("Light_1")
@onready var _a_Sprite_Light_2 = get_node("Light_2")

func turn_on():
	_a_Sprite_Light_1.set_modulate(_e_light_1_on_color)
	_a_Sprite_Light_2.set_modulate(_e_light_2_on_color)

func turn_off():
	_a_Sprite_Light_1.set_modulate(_e_light_off_color)
	_a_Sprite_Light_2.set_modulate(_e_light_off_color)
