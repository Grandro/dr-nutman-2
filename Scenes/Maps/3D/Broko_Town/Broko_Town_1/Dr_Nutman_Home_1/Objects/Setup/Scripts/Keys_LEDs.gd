extends Node3D

func set_modulate(p_color):
	for child in get_children():
		child.set_modulate(p_color)

func set_offset_color(p_idx, p_color):
	for child in get_children():
		child.set_offset_color(p_idx, p_color)
