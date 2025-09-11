extends "res://Scenes/Maps/3D/Broko_Town/Broko_Town_1/Buffin_House_3/Objects/Projectors/Scripts/Projector_Base.gd"

func _on_Interactions_interacted():
	var interaction_count = _a_Interactions.get_interaction_count(0)
	match interaction_count:
		1:
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene("Puzzle_2", "Start")
		2:
			var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene("Puzzle_2", "Projector_Start")
		_:
			super()
