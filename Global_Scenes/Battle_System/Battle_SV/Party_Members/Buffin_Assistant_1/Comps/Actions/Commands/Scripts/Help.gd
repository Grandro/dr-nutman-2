extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Actions/Scripts/Action_Base.gd"

func process():
	started.emit()
	pre_event.emit()
	
	var key = "Buffin_Assistant_Help_1"
	var help_count = _a_entity.get_help_count()
	var entry_key = str(help_count)
	_a_entity.cutscene(key, entry_key, _CB_cutscene_completed)

func _CB_cutscene_completed(_p_type, _p_key, _p_entry_key):
	_a_entity.inc_help_count()
	post_event.emit()
	_finished()
