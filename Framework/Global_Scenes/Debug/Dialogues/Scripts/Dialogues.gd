extends FWDebugKeysEditorParts
class_name FWDebugDialogues

signal part_moved(p_old_idx: int, p_new_idx: int, shift_others: bool)

@onready var _a_Options_Preview_All: Button = get_node("VBox/HBox/VBox/Options/Preview_All")
@onready var _a_Attributes: PanelContainer = get_node("VBox/HBox/VBox/Attributes")
@onready var _a_Text: FWDebugDialoguesAttributeText = get_node("VBox/HBox/VBox/Attributes/Text")
@onready var _a_Info: FWDebugDialoguesAttributeInfo = get_node("VBox/HBox/VBox/Attributes/Info")
@onready var _a_Choice: FWDebugDialoguesAttributeChoice = get_node("VBox/HBox/VBox/Attributes/Choice")

var _a_attr_instance: FWDebugDialoguesAttributeBase = null

func _ready() -> void:
	super()
	_a_Parts.entry_type_changed.connect(_on_Parts_entry_type_changed)
	_a_Parts.entry_type_changing.connect(_on_Parts_entry_type_changing)
	_a_Parts.entry_moved.connect(_on_Parts_entry_moved)
	_a_Parts.entry_tree_exited.connect(_on_Parts_entry_tree_exited)
	_a_Options_Preview_All.pressed.connect(_on_Options_Preview_All_pressed)
	
	for child: FWDebugDialoguesAttributeBase in _a_Attributes.get_children():
		child.hide()

func _open_attributes() -> void:
	var data: Dictionary = _a_part.get_data()
	var type: StringName = _a_part.get_type()
	match type:
		&"Text": _a_attr_instance = _a_Text
		&"Info": _a_attr_instance = _a_Info
		&"Choice": _a_attr_instance = _a_Choice
	_a_attr_instance.open(data[type])

func _close_attributes() -> void:
	if _a_attr_instance != null:
		_a_attr_instance.close()
		_a_attr_instance = null

func _update_part_data() -> void:
	if !is_instance_valid(_a_part):
		return
	
	var type: StringName = _a_part.get_type()
	var save_data: Dictionary = _a_attr_instance.get_save_data()
	_a_part.set_data_type(type, save_data)

func _selected_part_changed(p_instance: FWDebugEntryListEntry) -> void:
	super(p_instance)
	_close_attributes()
	_open_attributes()

func _set_keys_type(p_keys_type: StringName) -> void:
	super(p_keys_type)
	for child: FWDebugDialoguesAttributeBase in _a_Attributes.get_children():
		child.set_tabs_keys_type(p_keys_type)

func _on_Parts_entry_type_changed(p_instance: FWDebugEntryListTypeEntry) -> void:
	if _a_part != p_instance:
		return
	
	_close_attributes()
	_open_attributes()

func _on_Parts_entry_type_changing() -> void:
	_update_part_data()

func _on_Parts_entry_moved(p_old_idx: int, p_new_idx: int) -> void:
	part_moved.emit(p_old_idx, p_new_idx, true)

func _on_Parts_entry_tree_exited(p_idx: int) -> void:
	var child_count: int = _a_Parts.get_entry_count()
	for i: int in range(p_idx, child_count):
		part_moved.emit(i + 1, i, false)

func _on_Options_Preview_pressed() -> void:
	super()
	Debug.hide_menu()
	
	var key: StringName = _a_key_entry.get_key()
	var idx: int = _a_part.get_index()
	Dialogue_System.dialogue(key, null, &"Main", true, idx, idx, _a_keys_type)
	Dialogue_System.set_dialogue_completed_cb(key, _CB_dialogue_completed)
	Dialogue_System.set_dialogue_process_mode(key, ProcessMode.PROCESS_MODE_ALWAYS)

func _on_Options_Preview_All_pressed() -> void:
	_update_parts_data()
	Debug.hide_menu()
	
	var key: StringName = _a_key_entry.get_key()
	Dialogue_System.dialogue(key, null, &"Main", true, 0, -1, _a_keys_type)
	Dialogue_System.set_dialogue_completed_cb(key, _CB_dialogue_completed)
	Dialogue_System.set_dialogue_process_mode(key, ProcessMode.PROCESS_MODE_ALWAYS)

func _CB_dialogue_completed(_p_key: StringName) -> void:
	Debug.show_menu()
