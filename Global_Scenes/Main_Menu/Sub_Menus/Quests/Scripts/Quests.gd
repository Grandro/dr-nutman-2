extends Control

signal closed(p_data)

@onready var _a_Back = get_node("Back")
@onready var _a_Quest_List = get_node("Margin/HBox/Quest_List")
@onready var _a_Info = get_node("Margin/HBox/Info")

var _a_key = "" # Quest key

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	_a_Quest_List.entry_select_pressed.connect(_on_Quest_List_entry_select_pressed)
	_a_Info.pin_toggled.connect(_on_Info_pin_toggled)
	
	var entry_scene = load("res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Quest_Entry.tscn")
	_a_Quest_List.set_entry_scene(entry_scene)

func open(p_data):
	if p_data.is_empty():
		_a_Quest_List.instantiate_entries()
	else:
		_a_Quest_List.load_data(p_data["Quest_List"])
	
	if _a_Quest_List.get_child_count() > 0:
		var first = _a_Quest_List.get_entry(0)
		var key = first.get_key()
		_display_quest_entry_info(key)
	
	_tutato_explain()
	
	show()

func close():
	queue_free()
	
	var data = {}
	data["Quest_List"] = _a_Quest_List.get_save_data()
	closed.emit(data)

func _display_quest_entry_info(p_key):
	_a_Info.display(p_key)
	_a_key = p_key

func _tutato_explain():
	var progress_si = Global.get_singleton(self, "Progress")
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_quests = progress_si.call_object("Tutato", "get_explain_quests")
	if show_tutato_explain && explain_quests:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		var key = "Tutato_Explain"
		var entry_key = "Main_Menu_Quests"
		cutscene_system_si.cutscene(key, entry_key, "Main", "Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object("Tutato", "set_explain_quests", [false])
		
		_a_Back.set_select_diabled(true)

func _on_Back_select_pressed():
	close()

func _on_Quest_List_entry_select_pressed(p_instance):
	var key = p_instance.get_key()
	_display_quest_entry_info(key)

func _on_Info_pin_toggled(p_toggled):
	var progress_si = Global.get_singleton(self, "Progress")
	if p_toggled:
		progress_si.pin_quest(_a_key)
	else:
		progress_si.unpin_quest(_a_key)

func _CB_cutscene_completed(_p_process_type, p_key, p_entry_key):
	match p_key:
		"Tutato_Explain":
			match p_entry_key:
				"Main_Menu_Quests":
					_a_Back.set_select_diabled(false)
