extends Control
class_name MainMenuSubMenuOptions

signal closed(p_data: Dictionary)

@export_enum("Main_Menu", "Title_Screen") var _e_context: String = "Main_Menu"

@onready var _a_Back: IndicatorButton = get_node("Back")
@onready var _a_Tabs: TabContainer = get_node("Margin/VBox/Tabs")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	update_trans()
	
	var data: Dictionary = Global_Data.get_entry_data(&"Options")
	for child: MainMenuSubMenuOptionsOptionTab in _a_Tabs.get_children():
		var key: StringName = child.get_name()
		child.load_data(data[key])

func open(_p_data: Dictionary = {}) -> void:
	_tutato_explain()
	
	show()

func _close() -> void:
	Global_Data.save_data()
	
	match _e_context:
		&"Main_Menu": queue_free()
		&"Title_Screen": hide()
	
	var data: Dictionary = {}
	closed.emit(data)

func update_trans() -> void:
	var children: Array[Node] = _a_Tabs.get_children()
	for i: int in children.size():
		var child: MainMenuSubMenuOptionsOptionTab = children[i]
		var key: StringName = child.get_name()
		var text: String = tr("OPTIONS_%s" % key.to_upper())
		_a_Tabs.set_tab_title(i, text)

func _tutato_explain() -> void:
	if _e_context != &"Main_Menu":
		return
	
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_options: bool = progress_si.call_object(&"Tutato", &"get_explain_options")
	if show_tutato_explain && explain_options:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var key: StringName = &"Tutato_Explain"
		var entry_key: StringName = "Main_Menu_Options"
		cutscene_system_si.cutscene(key, entry_key, &"Main", &"Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object(&"Tutato", &"set_explain_options", [false])
		
		_a_Back.set_select_diabled(true)

func _on_Back_select_pressed() -> void:
	_close()

func _CB_cutscene_completed(_p_process_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	match p_key:
		&"Tutato_Explain":
			match p_entry_key:
				&"Main_Menu_Options":
					_a_Back.set_select_diabled(false)
