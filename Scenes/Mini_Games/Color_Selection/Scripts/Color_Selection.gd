extends FWMiniGameBase
class_name MiniGameColorSelection

func _on_Intro_proceed_pressed() -> void:
	if _e_in_nutOS:
		_a_game_play.show_result()
	else:
		_a_game_play.open_(true)
