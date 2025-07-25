extends MapBase3D

@onready var _a_Color_Selection = get_node("Mini_Games/Color_Selection")

func _ready():
	super()
	
	_a_Color_Selection.closed.connect(_on_Color_Selection_closed)

func open_color_selection():
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_player()
	player.comph().call_comp("Operate", "disable")
	
	_a_Color_Selection.open()

func _start():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Start_1", "0")

func load_data_init():
	super()
	
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	if show_tutato_explain:
		var global_si = Global.get_singleton(self, "Global")
		global_si.show_trans("", "Faded_Out")
		
		var tutato_explain = global_si.get_tutato_explain("Explain_Intro")
		tutato_explain.completed.connect(_on_Tutato_Explain_completed)
		tutato_explain.open()
	else:
		_start()

func _on_Color_Selection_closed():
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_player()
	player.comph().call_comp("Operate", "enable")
	
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Start_1", "1")

func _on_Tutato_Explain_completed():
	_start()
