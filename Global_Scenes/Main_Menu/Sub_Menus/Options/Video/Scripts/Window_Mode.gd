extends DebugValueSelectOptions
class_name MainMenuSubMenuOptionsVideoWindowMode

func _process(_p_delta: float) -> void:
	var window_mode: StringName
	match DisplayServer.window_get_mode():
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			window_mode = &"Fullscreen"
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			window_mode = &"Exclusive_Fullscreen"
		_:
			window_mode = &"Windowed"
	
	select(window_mode)
