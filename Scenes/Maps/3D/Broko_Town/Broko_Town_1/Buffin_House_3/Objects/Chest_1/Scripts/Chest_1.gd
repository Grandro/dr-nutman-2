extends "res://Scenes/Objects/3D/Chests/Scripts/Base.gd"

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Open":
			_a_opened = true
			_a_Interactions.set_interaction_allowed(false)
			
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene("Chest_1", "0")
