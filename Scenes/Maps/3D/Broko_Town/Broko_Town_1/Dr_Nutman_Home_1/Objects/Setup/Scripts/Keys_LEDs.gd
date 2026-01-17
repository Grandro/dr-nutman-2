extends Node3D
class_name ObjectSetupKeysLEDs

func set_modulate(p_color: Color) -> void:
	for child: ObjectSetupKeyLED in get_children():
		child.set_modulate(p_color)

func set_offset_color(p_idx: int, p_color: Color) -> void:
	for child: ObjectSetupKeyLED in get_children():
		child.set_offset_color(p_idx, p_color)
