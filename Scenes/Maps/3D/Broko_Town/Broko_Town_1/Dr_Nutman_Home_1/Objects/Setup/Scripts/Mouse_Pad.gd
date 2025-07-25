extends Node3D

@onready var _a_Color = get_node("Color")

func _ready():
	Global_Data.fav_color_changed.connect(_on_Global_Data_fav_color_changed)
	
	var fav_color = Global_Data.get_fav_color()
	_a_Color.set_modulate(fav_color)

func _on_Global_Data_fav_color_changed(p_color):
	_a_Color.set_modulate(p_color)
