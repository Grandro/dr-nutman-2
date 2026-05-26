extends FWMapBase3D
class_name MapDoctorDream1

@onready var _a_Color_Selection: MiniGameColorSelection = get_node("Mini_Games/Color_Selection")

func _ready() -> void:
	super()
	
	_a_Color_Selection.closed.connect(_on_Color_Selection_closed)

func open_color_selection() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: FWPlayer3D = global_si.get_object(&"Player")
	player.comph().call_comp("Operate", &"disable")
	
	_a_Color_Selection.open()

func _start() -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Start_1", &"0")

func load_data_init() -> void:
	super()
	
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	if show_tutato_explain:
		var global_si: Global = Global.get_singleton(self, "Global")
		global_si.show_trans("", &"Faded_Out")
		
		var tutato_explain: ObjectTutatoCompExplainBase2D = global_si.get_tutato_explain(&"Explain_Intro")
		tutato_explain.completed.connect(_on_Tutato_Explain_completed)
		tutato_explain.open()
	else:
		_start()

func _on_Color_Selection_closed() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var player: FWPlayer3D = global_si.get_object(&"Player")
	player.comph().call_comp("Operate", &"enable")
	
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Start_1", &"1")

func _on_Tutato_Explain_completed() -> void:
	_start()
