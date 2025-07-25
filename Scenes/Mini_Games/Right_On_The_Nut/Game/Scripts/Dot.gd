extends Node2D

@onready var _a_Inner = get_node("Inner")

func set_inner_progress(p_progress):
	var mat = _a_Inner.get_material()
	mat.set_shader_parameter("progress", p_progress)
