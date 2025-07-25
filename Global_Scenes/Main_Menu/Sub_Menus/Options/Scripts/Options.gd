extends Control

signal closed(p_data)

@export_enum("Main_Menu", "Title_Screen") var _e_context = "Main_Menu"

@onready var _a_Back = get_node("Back")
@onready var _a_Tabs = get_node("Margin/VBox/Tabs")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	update_trans()
	
	var data = Global_Data.get_entry_data("Options")
	for child in _a_Tabs.get_children():
		var key = child.get_name()
		child.load_data(data[key])

func open(_p_data = {}):
	_tutato_explain()
	
	show()

func _close():
	Global_Data.save_data()
	
	match _e_context:
		"Main_Menu": queue_free()
		"Title_Screen": hide()
	
	var data = {}
	closed.emit(data)

func update_trans():
	var children = _a_Tabs.get_children()
	for i in children.size():
		var child = children[i]
		var key = child.get_name()
		var text = tr("OPTIONS_%s" % key.to_upper())
		_a_Tabs.set_tab_title(i, text)

func _tutato_explain():
	if _e_context != "Main_Menu":
		return
	
	var progress_si = Global.get_singleton(self, "Progress")
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_options = progress_si.call_object("Tutato", "get_explain_options")
	if show_tutato_explain && explain_options:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		var key = "Tutato_Explain"
		var entry_key = "Main_Menu_Options"
		cutscene_system_si.cutscene(key, entry_key, "Main", "Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object("Tutato", "set_explain_options", [false])
		
		_a_Back.set_select_diabled(true)

func _on_Back_select_pressed():
	_close()

func _CB_cutscene_completed(_p_process_type, p_key, p_entry_key):
	match p_key:
		"Tutato_Explain":
			match p_entry_key:
				"Main_Menu_Options":
					_a_Back.set_select_diabled(false)
