extends MapBase3D

@onready var _a_Citrin_1 = get_node("Objects/Citrin_1")
@onready var _a_Citrin_2 = get_node("Objects/Citrin_2")
@onready var _a_Enemy_Stay_Area_Citrins_1 = get_node("Enemy_Stay_Areas/Citrins_1")
@onready var _a_Enemy_Stay_Area_Citrins_2 = get_node("Enemy_Stay_Areas/Citrins_2")

func _ready():
	super()
	_a_Citrin_1.comph().call_comp("Behavior", "set_stay_area", [_a_Enemy_Stay_Area_Citrins_1])
	_a_Citrin_2.comph().call_comp("Behavior", "set_stay_area", [_a_Enemy_Stay_Area_Citrins_2])

func load_data_init():
	super()
	
	_tutato_explain()

func _tutato_explain():
	var progress_si = Global.get_singleton(self, "Progress")
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_on_map_encounter = progress_si.call_object("Tutato", "get_explain_on_map_encounter")
	if show_tutato_explain && explain_on_map_encounter:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		cutscene_system_si.cutscene("Tutato_Explain", "On_Map_Encounter", "Main", "Global")
		progress_si.call_object("Tutato", "set_explain_on_map_encounter", [false])
