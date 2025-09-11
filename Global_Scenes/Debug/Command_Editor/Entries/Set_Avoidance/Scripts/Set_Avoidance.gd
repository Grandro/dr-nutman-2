extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Object.gd"

func _update_display_main_base_args():
	var object_text = _get_display_text(_a_data["Object"])
	var avoidance_text = _get_display_text(_a_data["Avoidance"])
	
	var text = object_text
	text += ", %s" % avoidance_text
	_a_Main.set_base_args(text)
