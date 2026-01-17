extends MiniGameColorSelectionFlipper1Base
class_name MiniGameColorSelectionFlipper1Right

func _process(p_delta: float) -> void:
	if Input.is_action_pressed(&"ui_right"):
		rotation_degrees += 10.0 * _e_speed * p_delta
	else:
		rotation_degrees -= 10.0 * _e_speed * p_delta
	rotation_degrees = clamp(rotation_degrees, -30.0, 30.0)

func _input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"ui_right"):
		_a_Audio_Flip.play()
