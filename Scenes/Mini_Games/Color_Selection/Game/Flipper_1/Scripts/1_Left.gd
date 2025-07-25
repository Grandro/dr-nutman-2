extends "res://Scenes/Mini_Games/Color_Selection/Game/Flipper_1/Scripts/1_Base.gd"

func _process(p_delta):
	if Input.is_action_pressed("ui_left"):
		rotation_degrees -= 10 * _e_speed * p_delta
	else:
		rotation_degrees += 10 * _e_speed * p_delta
	rotation_degrees = clamp(rotation_degrees, -30, 30)

func _input(p_event):
	if p_event.is_action_pressed("ui_left"):
		_a_Audio_Flip.play()
