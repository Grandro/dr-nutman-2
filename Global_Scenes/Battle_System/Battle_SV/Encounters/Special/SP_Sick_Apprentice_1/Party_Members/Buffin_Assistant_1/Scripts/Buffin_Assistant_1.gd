extends "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Scripts/Party_Member_Battle.gd"

var _a_help_count = 0

func process_action_start():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var key = "Buffin_Assistant_Help_1"
	var entry_key = str(_a_help_count)
	cutscene_system_si.cutscene(key, entry_key)
	cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)

func _CB_cutscene_completed(_p_type, _p_key, _p_entry_key):
	_a_help_count += 1
	_emit_turn_completed()
