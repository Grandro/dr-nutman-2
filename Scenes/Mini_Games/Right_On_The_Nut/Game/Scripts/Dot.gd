extends Node2D
class_name MiniGameRightOnTheNutDot

@onready var _a_Inner: Sprite2D = get_node("Inner")

func set_inner_progress(p_progress: float) -> void:
	var mat: ShaderMaterial = _a_Inner.get_material()
	mat.set_shader_parameter(&"progress", p_progress)
