extends MapBase3D
class_name MapBrokoForest1

func load_data_init() -> void:
	super()
	
	_tutato_explain()

func _tutato_explain() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_on_map_encounter: bool = progress_si.call_object(&"Tutato", &"get_explain_on_map_encounter")
	if show_tutato_explain && explain_on_map_encounter:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		cutscene_system_si.cutscene(&"Tutato_Explain", &"On_Map_Encounter", &"Main", &"Global")
		progress_si.call_object(&"Tutato", &"set_explain_on_map_encounter", [false])
