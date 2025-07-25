extends "res://Scenes/Mini_Games/Mini_Game_Base/Scripts/Mini_Game_Base.gd"

func _on_Intro_proceed_pressed():
	if _e_in_nutOS:
		_a_game_play.show_result()
	else:
		_a_game_play.open_(true)
