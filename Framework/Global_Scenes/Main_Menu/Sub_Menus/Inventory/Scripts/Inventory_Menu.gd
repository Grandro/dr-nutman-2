extends FWItemSelectBaseMenu
class_name MainMenuSubMenuInventory

signal closed(p_data: Dictionary)

@onready var _a_Inventory: FWItemSelectInventory = get_node("Inventory")

func open(_p_data: Dictionary) -> void:
	_a_Inventory.open()
	_tutato_explain()
	
	show()

func close() -> void:
	queue_free()
	
	var data: Dictionary = {}
	closed.emit(data)

func _tutato_explain() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_inventory: bool = progress_si.call_object(&"Tutato", &"get_explain_inventory")
	if show_tutato_explain && explain_inventory:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var key: StringName = &"Tutato_Explain"
		var entry_key: StringName = &"Main_Menu_Inventory"
		cutscene_system_si.cutscene(key, entry_key, &"Main", &"Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object(&"Tutato", &"set_explain_inventory", [false])
		
		_a_Back.set_select_diabled(true)
		_a_Inventory.set_info_options_disabled(true)

func _CB_cutscene_completed(_p_process_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	match p_key:
		&"Tutato_Explain":
			match p_entry_key:
				&"Main_Menu_Inventory":
					_a_Back.set_select_diabled(false)
					_a_Inventory.set_info_options_disabled(false)
