extends "res://Scenes/Object/Comps/3D/Scripts/Display.gd"

func tween_tint(p_color, p_duration):
	var mat = get_material_override()
	mat.set_shader_parameter("color_B", p_color)
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/progress", 1.0, p_duration).from(0.0)
