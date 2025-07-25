extends "res://Global_Scenes/Main_Menu/Menus/Scripts/Menu_Base.gd"

@onready var _a_Menu_Icons = get_node("VBox/Menu_Icons")
@onready var _a_Back = get_node("Back")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	_init_menu_icons(_a_Menu_Icons)

func open():
	super()
	
	_tutato_explain()

func _tutato_explain():
	var progress_si = Global.get_singleton(self, "Progress")
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_journal = progress_si.call_object("Tutato", "get_explain_journal")
	if show_tutato_explain && explain_journal:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		var key = "Tutato_Explain"
		var entry_key = "Main_Menu_Journal"
		cutscene_system_si.cutscene(key, entry_key, "Main", "Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object("Tutato", "set_explain_journal", [false])
		
		_a_Back.set_select_diabled(true)
		for child in _a_Menu_Icons.get_children():
			child.set_image_disabled(true)

func _on_Back_select_pressed():
	close()

func _CB_cutscene_completed(_p_process_type, p_key, p_entry_key):
	match p_key:
		"Tutato_Explain":
			match p_entry_key:
				"Main_Menu_Journal":
					_a_Back.set_select_diabled(false)
					for child in _a_Menu_Icons.get_children():
						child.set_image_disabled(false)
