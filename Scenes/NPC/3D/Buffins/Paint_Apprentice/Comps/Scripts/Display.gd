extends CompDisplay3D
class_name CompPaintApprenticeDisplay

func tween_tint(p_color: Color, p_duration: float) -> void:
	var mat: Material = get_material_override()
	var tween: Tween = create_tween()
	mat.set_shader_parameter(&"color_B", p_color)
	tween.tween_property(mat, "shader_parameter/progress", 1.0, p_duration).from(0.0)
