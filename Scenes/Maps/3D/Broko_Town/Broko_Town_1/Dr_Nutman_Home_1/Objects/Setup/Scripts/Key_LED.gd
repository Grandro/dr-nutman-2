extends Sprite3D
class_name ObjectSetupKeyLED

func set_offset_color(p_idx: int, p_color: Color) -> void:
	var tex: Texture2D = get_texture()
	var gradient: Gradient = tex.get_gradient()
	gradient.set_color(p_idx, p_color)
