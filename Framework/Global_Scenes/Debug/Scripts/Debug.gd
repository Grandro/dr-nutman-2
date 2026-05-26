extends Node
class_name FWDebug

signal loc_data_loaded()
signal closing()

@export var _e_enabled: bool = true

const _a_DEFAULT_VOX_FILE_PATH: String = "res://Global_Resources/Audio/SFX/Vox/Default.ogg"

@onready var _a_Teleport_Map: FWDebugTeleportMap = get_node("Teleport_Map")
@onready var _a_Window: FWWindowBase = get_node("Window")
@onready var _a_Menu: TabContainer = get_node("Window/Control/Menu")
@onready var _a_Dialogues: FWDebugDialogues = get_node("Window/Control/Menu/Dialogues")
@onready var _a_Stater: FWDebugStater = get_node("Window/Control/Menu/Stater")
@onready var _a_Cutscenes: FWDebugCutscenes = get_node("Window/Control/Menu/Cutscenes")
@onready var _a_Localization: FWDebugLocEditor = get_node("Window/Control/Menu/Localization")
@onready var _a_Commands_List: FWDebugCommandsList = get_node("Window/Commands_List")
@onready var _a_Command_Edit: FWDebugCommandEdit = get_node("Window/Command_Edit")
@onready var _a_Fix_Warnings: FWDebugFixWarnings = get_node("Window/Fix_Warnings")
@onready var _a_Attr_Select: FWDebugAttrSelect = get_node("Window/Attr_Select")
@onready var _a_Loc_Editor: FWDebugLocEditor = get_node("Window/Loc_Editor/Loc_Editor")
@onready var _a_Messages: FWMessages = get_node("Window/Messages")

var _a_loc_data: Dictionary[String, Dictionary] = {} # Match prefix to loc_data
var _a_loc_data_modified_time: Dictionary[String, int] = {} # Match prefix to modified_time
var _a_command_editor_clipboard: Array[Dictionary] = []
var _a_curr_menu_tab: MarginContainer = null

func _ready() -> void:
	if !_e_enabled || !OS.is_debug_build():
		await get_tree().process_frame
		queue_free()
		return
	
	var root: Window = get_tree().get_root()
	closing.connect(_on_closing)
	root.focus_entered.connect(_on_Window_focus_entered)
	_a_Window.close_requested.connect(_on_Window_close_requested)
	_a_Window.focus_entered.connect(_on_Window_focus_entered)
	_a_Menu.tab_changed.connect(_on_Menu_tab_changed)
	_a_Dialogues.key_changed.connect(_a_Stater._on_Dialogues_key_changed)
	_a_Dialogues.part_moved.connect(_a_Stater._on_Dialogues_part_moved)
	_a_Dialogues.key_changed.connect(_a_Cutscenes._on_Dialogues_key_changed)
	_a_Dialogues.part_moved.connect(_a_Cutscenes._on_Dialogues_part_moved)
	_a_Localization.trans_changed.connect(_on_Localization_trans_changed)
	
	_init_loc_data()
	
	_a_Window.hide()

func _init_loc_data() -> void:
	var translations: Array[Translation] = TranslationServer.get_translations()
	for translation: Translation in translations:
		var path: String = translation.get_path()
		var first_dot_idx: int = path.find(".")
		var prefix: String = path.left(first_dot_idx)
		var loc_data: Dictionary = Data_Parser.load_loc_data(prefix)
		_a_loc_data[prefix] = loc_data
		_a_loc_data_modified_time[prefix] = -1
	
	loc_data_loaded.emit()

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Open_Debug"):
		if _a_Window.is_visible():
			closing.emit()
			close()
		else:
			open()

func open() -> void:
	Global.pause()
	_a_Window.show()

func close() -> void:
	Global.unpause()
	set_openable(true)
	_a_Window.hide()

func open_teleport_map() -> void:
	_a_Teleport_Map.open()

func grab_window_focus() -> void:
	_a_Window.grab_focus()

func show_menu() -> void:
	set_openable(true)
	_a_Window.show()

func hide_menu() -> void:
	set_openable(false)
	_a_Window.hide()

func update_all_trans() -> void:
	var instances: Array[Node] = get_tree().get_nodes_in_group(&"Translated")
	for instance: Node in instances:
		instance.update_trans()

func add_loc_id(p_prefix: String, p_loc_id: StringName, p_value: Dictionary[StringName, String] = {}) -> void:
	if p_value.is_empty():
		var locales: PackedStringArray = TranslationServer.get_loaded_locales()
		for locale: String in locales:
			p_value[locale] = "-"
	
	_a_loc_data[p_prefix][p_loc_id] = p_value

func erase_loc_id(p_prefix: String, p_loc_id: StringName) -> void:
	_a_loc_data[p_prefix].erase(p_loc_id)

func fix_data_dialogue_key(p_args: Dictionary, p_old: StringName, p_new: StringName) -> void:
	if p_args[&"Args"].has(&"Branches"):
		for branch: int in p_args[&"Args"][&"Branches"]:
			var branch_args: Dictionary = p_args[&"Args"][&"Branches"][branch]
			for entry_args: Dictionary in branch_args[&"Entries"]:
				fix_data_dialogue_key(entry_args, p_old, p_new)
	
	var command: StringName = p_args[&"Command"]
	match command:
		&"Match":
			var choices_data: Dictionary = p_args[&"Data"][&"Menus"][&"Choices"]
			var key: Variant = choices_data[&"Dialogue"][&"Value"]
			if key == p_old:
				choices_data[&"Dialogue"][&"Value"] = p_new
		
		&"Show_Dialogue":
			var key: StringName = p_args[&"Data"][&"Key"][&"Value"]
			if key == p_old:
				p_args[&"Data"][&"Key"][&"Value"] = p_new

func fix_data_dialogue_part_idx(p_args: Dictionary, p_idx_shifts: Dictionary[int, int]) -> void:
	if p_args[&"Args"].has(&"Branches"):
		for branch: int in p_args[&"Args"][&"Branches"]:
			var branch_args: Dictionary = p_args[&"Args"][&"Branches"][branch]
			for entry_args: Dictionary in branch_args[&"Entries"]:
				fix_data_dialogue_part_idx(entry_args, p_idx_shifts)
	
	var command: StringName = p_args[&"Command"]
	match command:
		&"Match":
			var choices_data: Dictionary = p_args[&"Data"][&"Menus"][&"Choices"]
			var part_entry_key: StringName = choices_data[&"Part"][&"Value"]
			for old_idx: int in p_idx_shifts:
				if part_entry_key == StringName(str(old_idx)):
					choices_data[&"Part"][&"Value"] = StringName(str(p_idx_shifts[old_idx]))
					break

func set_openable(p_openable: bool) -> void:
	set_process_unhandled_input(p_openable)

func get_commands_list() -> FWDebugCommandsList:
	return _a_Commands_List

func get_command_edit() -> FWDebugCommandEdit:
	return _a_Command_Edit

func get_fix_warnings() -> FWDebugFixWarnings:
	return _a_Fix_Warnings

func get_attr_select() -> FWDebugAttrSelect:
	return _a_Attr_Select

func get_loc_editor() -> FWDebugLocEditor:
	return _a_Loc_Editor

func get_messages() -> FWMessages:
	return _a_Messages

func set_command_editor_clipboard(p_command_editor_clipboard: Array[Dictionary]) -> void:
	_a_command_editor_clipboard = p_command_editor_clipboard

func get_command_editor_clipboard() -> Array[Dictionary]:
	return _a_command_editor_clipboard

func get_loc_data(p_prefix: String) -> Dictionary:
	return _a_loc_data[p_prefix]

func is_type_tween_supported(p_type: Variant.Type) -> bool:
	if p_type == TYPE_BOOL || p_type == TYPE_INT:
		return true
	if p_type == TYPE_FLOAT || p_type == TYPE_VECTOR2:
		return true
	if p_type == TYPE_RECT2 || p_type == TYPE_VECTOR3:
		return true
	if p_type == TYPE_TRANSFORM2D || p_type == TYPE_QUATERNION:
		return true
	if p_type == TYPE_AABB || p_type == TYPE_BASIS:
		return true
	if p_type == TYPE_TRANSFORM3D || p_type == TYPE_COLOR:
		return true
	
	return false

func is_usage_for_editor(p_usage: PropertyUsageFlags) -> bool:
	if p_usage == PROPERTY_USAGE_NONE:
		return true
	if Global.is_bit_enabled(p_usage, 0):
		return true
	if Global.is_bit_enabled(p_usage, 1):
		return true
	if Global.is_bit_enabled(p_usage, 2):
		return true
	if Global.is_bit_enabled(p_usage, 12):
		return true
	
	return false

func _on_closing() -> void:
	_a_Commands_List.close()
	_a_Command_Edit.close()

func _on_request_hide() -> void:
	set_openable(false)
	_a_Window.hide()

func _on_request_close() -> void:
	close()

func _on_Window_close_requested() -> void:
	close()

func _on_Window_focus_entered() -> void:
	if !_e_enabled || !OS.is_debug_build():
		return
	
	for prefix: String in _a_loc_data:
		var path: String = "%s.csv" % prefix
		var modified_time: int = FileAccess.get_modified_time(path)
		if modified_time > _a_loc_data_modified_time[prefix]:
			_a_loc_data[prefix] = Data_Parser.load_loc_data(prefix)
			_a_loc_data_modified_time[prefix] = modified_time

func _on_Menu_tab_changed(p_idx: int) -> void:
	var instance: MarginContainer = _a_Menu.get_tab_control(p_idx)
	if instance == _a_Localization:
		_a_Localization.open()
	elif _a_curr_menu_tab == _a_Localization:
		_a_Localization.close()
	
	_a_curr_menu_tab = instance

func _on_Localization_trans_changed() -> void:
	update_all_trans()
