extends MainMenuMenuBase
class_name MainMenuMenuJournal

@onready var _a_Menu_Icons: HBoxContainer = get_node("VBox/Menu_Icons")
@onready var _a_Back: IndicatorButton = get_node("Back")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	_init_menu_icons(_a_Menu_Icons)

func open() -> void:
	super()
	
	_tutato_explain()

func _tutato_explain() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var show_tutato_explain: bool = Global_Data.get_options_gameplay_show_tutato_explain()
	var explain_journal: bool = progress_si.call_object(&"Tutato", &"get_explain_journal")
	if show_tutato_explain && explain_journal:
		var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
		var key: StringName = &"Tutato_Explain"
		var entry_key: StringName = &"Main_Menu_Journal"
		cutscene_system_si.cutscene(key, entry_key, &"Main", &"Global")
		cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _CB_cutscene_completed)
		cutscene_system_si.set_cutscene_process_mode(key, entry_key, ProcessMode.PROCESS_MODE_ALWAYS)
		progress_si.call_object(&"Tutato", &"set_explain_journal", [false])
		
		_a_Back.set_select_diabled(true)
		for child: MainMenuMenuIcon in _a_Menu_Icons.get_children():
			child.set_image_disabled(true)

func _on_Back_select_pressed() -> void:
	close()

func _CB_cutscene_completed(_p_process_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	match p_key:
		&"Tutato_Explain":
			match p_entry_key:
				&"Main_Menu_Journal":
					_a_Back.set_select_diabled(false)
					for child: MainMenuMenuIcon in _a_Menu_Icons.get_children():
						child.set_image_disabled(false)
