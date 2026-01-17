extends ObjectProjectorBase
class_name MapBuffinHouse3ObjectProjector1

func _on_Interactions_interacted() -> void:
	var interaction_count: int = _a_Interactions.get_interaction_count(0)
	match interaction_count:
		1:
			var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene(&"Puzzle_2", &"Start")
		2:
			var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
			cutscene_system_si.cutscene(&"Puzzle_2", &"Projector_Start")
		_:
			super()
