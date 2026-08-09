extends Control
class_name MainMenuSubMenuJournal

signal closed(p_data: Dictionary)

@export_enum("Main_Menu", "Title_Screen") var _e_context: String = "Main_Menu"
@export_enum("Read", "Write") var _e_state: String = "Read"

@onready var _a_Back: FWIndicatorButton = get_node("Back")
@onready var _a_Heading: Label = get_node("VBox/Heading")
@onready var _a_Entries: HBoxContainer = get_node("VBox/Entries")
@onready var _a_Arrow: TextureRect = get_node("Arrow")

var _a_idx: int

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	var save_file_idx: int = Global_Data.get_save_file_idx()
	_a_idx = max(0, save_file_idx - 1)
	
	_init_entries()
	_set_heading(_e_state)

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"ui_cancel"):
		_close()

func open(_p_data: Dictionary = {}) -> void:
	set_process_unhandled_input(true)
	show()
	
	var child: MainMenuSubMenuJournalFileEntry = _a_Entries.get_child(_a_idx)
	child.grab_select_focus.call_deferred()

func _close(p_exit: bool = false) -> void:
	match _e_context:
		&"Main_Menu":
			if p_exit:
				Main_Menu.close()
			queue_free()
		
		&"Title_Screen":
			set_process_unhandled_input(false)
			hide()
	
	var data: Dictionary = {}
	closed.emit(data)

func _init_entries() -> void:
	var children: Array[Node] = _a_Entries.get_children()
	for i: int in children.size():
		var child: MainMenuSubMenuJournalFileEntry = children[i]
		child.select_pressed.connect(_on_Entry_Select_pressed.bind(child))
		child.select_focus_entered.connect(_on_Entry_Select_focus_entered.bind(i))
		
		var path: String = Global.get_save_path() % [str(i + 1), "Save"]
		var empty: bool = !FileAccess.file_exists(path)
		if !empty:
			var data: Dictionary = Data_Parser.load_var_data(path)
			child.update_display(data)
		child.set_empty(empty)

func _change_arrow_pos(p_idx: int) -> void:
	var instance: MainMenuSubMenuJournalFileEntry = _a_Entries.get_child(p_idx)
	var size_x: float = instance.get_size().x
	var pos_x: float = instance.get_global_position().x
	var arrow_size_x: float = _a_Arrow.get_size().x
	var arrow_pos_x: float = pos_x + (0.5 * size_x) - (0.5 * arrow_size_x)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_a_Arrow, "position:x", arrow_pos_x, 0.2)

func _set_heading(p_state: String) -> void:
	_a_Heading.set_text(tr("FW_MAIN_MENU_JOURNAL_%s" % p_state.to_upper()))

func _on_Back_select_pressed() -> void:
	_close()

func _on_Entry_Select_pressed(p_instance: MainMenuSubMenuJournalFileEntry) -> void:
	var messages_si: Messages = Global.get_singleton(self, "Messages")
	match _e_state:
		&"Write":
			set_process_unhandled_input(false)
			messages_si.show_proceed(tr(&"FW_WRITE_READ_PROCEEDWRITE"), _CB_Messages_Proceed.bind(p_instance))
		&"Read":
			if !p_instance.is_empty():
				set_process_unhandled_input(false)
				messages_si.show_proceed(tr(&"FW_WRITE_READ_PROCEEDREAD"), _CB_Messages_Proceed.bind(p_instance))

func _on_Entry_Select_focus_entered(p_idx: int) -> void:
	Global_Data.set_save_file_idx(p_idx + 1)
	Global_Data.save_data()
	
	_change_arrow_pos(p_idx)
	_a_idx = p_idx

func _CB_Messages_Proceed(p_response: StringName, p_instance: MainMenuSubMenuJournalFileEntry) -> void:
	match p_response:
		&"Yes":
			var save_file_idx: int = _a_idx + 1
			var global_si: Global = Global.get_singleton(self, "Global")
			match _e_state:
				&"Write": global_si.save_file_data_idx(save_file_idx)
				&"Read": global_si.load_file_data(save_file_idx, "Save")
			_close(true)
		&"No":
			p_instance.grab_select_focus()
	
	set_process_unhandled_input(true)
