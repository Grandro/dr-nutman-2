extends "res://Scenes/Item_Select_Base_Menu/Scripts/Item_Select_Base_Menu.gd"

signal closed(p_data)

@onready var _a_Heading = get_node("Heading")
@onready var _a_Inventory = get_node("Inventory")

func update_trans():
	_a_Heading.set_text(tr("MAIN_MENU_INVENTORY"))

func open(_p_data):
	_a_Inventory.open()
	_tutato_explain()
	
	show()

func close():
	queue_free()
	
	var data = {}
	closed.emit(data)

func _tutato_explain():
	var progress_si = Global.get_singleton(self, "Progress")
	var show_tutato_explain = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_inventory = progress_si.call_object("Tutato", "get_explain_inventory")
	if show_tutato_explain && explain_inventory:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		var key = "Tutato_Explain"
		var entry_key = "Main_Menu_Inventory"
		cutscene_system_si.cutscene(key, entry_key, "Main", "Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object("Tutato", "set_explain_inventory", [false])
		
		_a_Back.set_select_diabled(true)
		_a_Inventory.set_info_options_disabled(true)

func _CB_cutscene_completed(_p_process_type, p_key, p_entry_key):
	match p_key:
		"Tutato_Explain":
			match p_entry_key:
				"Main_Menu_Inventory":
					_a_Back.set_select_diabled(false)
					_a_Inventory.set_info_options_disabled(false)
