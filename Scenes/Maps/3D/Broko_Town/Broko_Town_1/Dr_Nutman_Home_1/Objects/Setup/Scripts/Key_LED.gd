extends Sprite3D

func set_offset_color(p_idx, p_color):
	var tex = get_texture()
	var gradient = tex.get_gradient()
	gradient.set_color(p_idx, p_color)
