extends "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Scripts/Party_Member_Battle.gd"

var _a_help_count = 0

func inc_help_count():
	_a_help_count += 1

func get_help_count():
	return _a_help_count
