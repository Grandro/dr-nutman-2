extends "res://Scenes/Objects/3D/Chests/Scripts/Base.gd"

@export var _e_key : String = ""
@export var _e_entry_key : String = ""

func _opened():
	super()
	
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(_e_key, _e_entry_key)
