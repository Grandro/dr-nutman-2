extends MarginContainer
class_name FWDebugKeysEditor

signal key_changed(p_old_key: StringName, p_new_key: StringName)

@export var _e_key: StringName = &""

const _a_KEYS_TYPE_LOC_ID: String = "FW_DEBUG_TYPE_%s"

var _a_Key_Entry_Scene: PackedScene = preload("uid://ba6gse1qaquq8")

@onready var _a_HBox: HBoxContainer = get_node("HBox")
@onready var _a_Keys_Types: FWKeyEntryToggler = get_node("HBox/VBox/Keys_Types")
@onready var _a_Sort_By: FWSortBy = get_node("HBox/VBox/Options/Sort_By")
@onready var _a_Search: FWSearch = get_node("HBox/VBox/Options/Search")
@onready var _a_Keys: HFlowContainer = get_node("HBox/VBox/Scroll/Keys")
@onready var _a_Add: LineEdit = get_node("HBox/VBox/Add")
@onready var _a_Save: Button = get_node("HBox/Options/Save")

var _a_key_entry: FWDebugKeysEditorKeyEntry = null # Currently selected key_entry
var _a_keys_entries: Dictionary[StringName, FWDebugKeysEditorKeyEntry] = {} # Match key to key_entry
var _a_keys_type: StringName = &"Map" # Map/Global

func _ready() -> void:
	_a_Keys_Types.toggled.connect(_on_Keys_Types_toggled)
	_a_Sort_By.option_selected.connect(_on_Sort_By_option_selected)
	_a_Search.input_text_changed.connect(_on_Search_input_text_changed)
	_a_Add.text_submitted.connect(_on_Add_text_submitted)
	_a_Save.pressed.connect(_on_Save_pressed)
	Progress.chapter_changed.connect(_on_Progress_chapter_changed)
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	_create_keys_types()
	_a_HBox.show()

func _open() -> void:
	pass

func _create_keys_types() -> void:
	for keys_type: StringName in [&"Map", &"Global"]:
		var select_text: String = tr(_a_KEYS_TYPE_LOC_ID % keys_type.to_upper())
		var instance: FWEntryTogglerKeyEntry = _a_Keys_Types.instantiate_entry_(select_text, null, keys_type)
		_a_Keys_Types.add_entry(instance)

func _select_next_entry(p_idx: int) -> void:
	var child_count: int = _a_Keys.get_child_count()
	if child_count > p_idx:
		var child: FWDebugKeysEditorKeyEntry = _a_Keys.get_child(p_idx)
		_select_entry(child)

func _select_entry(p_instance: FWDebugKeysEditorKeyEntry) -> void:
	p_instance.select()
	_a_key_entry = p_instance

func _update_key_entries() -> void:
	_clear_key_entries()
	if !Scene_Manager.is_curr_scene_map_encounter():
		return
	
	var data: Dictionary = _get_data()
	for key: StringName in data:
		var entry_data: Dictionary = data[key]
		var time_created: float = entry_data[&"Time_Created"]
		var instance: FWDebugKeysEditorKeyEntry = _instantiate_key_entry(key, time_created, entry_data[&"Data"])
		
		_a_Keys.add_child(instance)
	
	_select_next_entry.call_deferred(0)

func _create_new_key_entry(p_key: StringName, p_data: Dictionary = {}) -> void:
	var time_created: float = Time.get_unix_time_from_system()
	var instance: FWDebugKeysEditorKeyEntry = _instantiate_key_entry(p_key, time_created, p_data)
	instance.ready.connect(_on_Key_Entry_ready)
	
	_a_Keys.add_child(instance)

func _instantiate_key_entry(p_key: StringName, p_time_created: float, p_data: Dictionary = {}) -> FWDebugKeysEditorKeyEntry:
	var instance: FWDebugKeysEditorKeyEntry = _a_Key_Entry_Scene.instantiate()
	instance.request_key.connect(_on_Key_Entry_request_key.bind(instance))
	instance.selected.connect(_on_Key_Entry_selected.bind(instance))
	instance.pressed.connect(_on_Key_Entry_pressed)
	instance.duplicate_pressed.connect(_on_Key_Entry_duplicate_pressed.bind(instance))
	instance.tree_exiting.connect(_on_Key_Entry_tree_exiting.bind(instance))
	instance.set_key.call_deferred(p_key)
	instance.set_time_created(p_time_created)
	instance.set_data(p_data)
	
	_a_keys_entries[p_key] = instance
	
	return instance

func _clear_key_entries() -> void:
	_a_keys_entries.clear()
	for child: FWDebugKeysEditorKeyEntry in _a_Keys.get_children():
		child.queue_free()

func _sort_items() -> void:
	var args: Array = _a_Sort_By.get_selected_args()
	var method_name: StringName = args[0]
	var rel: String = args[1]
	FWPropertySorter.sort(_a_Keys, method_name, rel)

func _update_data() -> void:
	if !Scene_Manager.is_curr_scene_map_encounter():
		return
	
	var data: Dictionary = _get_data()
	data.clear()
	for child: FWDebugKeysEditorKeyEntry in _a_Keys.get_children():
		var key: StringName = child.get_key()
		data[key] = {}
		data[key][&"Data"] = child.get_data()
		data[key][&"Time_Created"] = child.get_time_created()

func _save_data() -> void:
	_update_data()
	Databases.write_data(&"Debug")

func _set_keys_type(p_keys_type: StringName) -> void:
	_a_keys_type = p_keys_type

func _is_key_used(p_key: StringName) -> bool:
	return _a_keys_entries.has(p_key)

func _get_data() -> Dictionary:
	var debug_data: Dictionary = Databases.get_debug_data(_e_key)
	var data: Dictionary = debug_data[_a_keys_type]
	if _a_keys_type == &"Map":
		var chapter: StringName = Progress.get_chapter()
		var location: StringName = Scene_Manager.get_location()
		var chapter_data: Dictionary = data.get_or_add(chapter, {})
		data = chapter_data.get_or_add(location, {})
	
	return data

func _on_Keys_Types_toggled(p_instance: FWEntryTogglerKeyEntry) -> void:
	_update_data()
	
	var keys_type: StringName = p_instance.get_key()
	_set_keys_type(keys_type)
	_update_key_entries()

func _on_Sort_By_option_selected() -> void:
	_sort_items()

func _on_Search_input_text_changed(p_text: String) -> void:
	var upper_text: String = p_text.to_upper()
	for child: FWDebugKeysEditorKeyEntry in _a_Keys.get_children():
		if upper_text.is_empty():
			child.show()
			continue
		
		var key: StringName = child.get_key()
		if upper_text in key.to_upper():
			child.show()
		else:
			child.hide()

func _on_Add_text_submitted(p_key: StringName) -> void:
	if _is_key_used(p_key):
		var messages: Messages = Debug.get_messages()
		messages.show_info(tr(&"FW_DEBUG_KEY_IN_USE"))
	else:
		_create_new_key_entry(p_key)
		_a_Add.clear()

func _on_Save_pressed() -> void:
	_save_data()

func _on_Progress_chapter_changed(_p_chapter: StringName) -> void:
	if _a_keys_type == &"Map":
		_update_key_entries()

func _on_Scene_Manager_scene_changed(_p_instance: Node, _p_loaded_file_data: bool) -> void:
	if _a_keys_type == &"Map":
		_update_key_entries.call_deferred()

func _on_Key_Entry_request_key(p_key: StringName, p_instance: FWDebugKeysEditorKeyEntry) -> void:
	if _is_key_used(p_key):
		var messages: Messages = Debug.get_messages()
		messages.show_info(tr(&"FW_DEBUG_KEY_IN_USE"))
		return
	
	var old_key: StringName = p_instance.get_key()
	_a_keys_entries.erase(old_key)
	_a_keys_entries[p_key] = p_instance
	p_instance.set_key(p_key)
	p_instance.set_text("")
	_update_data()
	
	key_changed.emit(old_key, p_key)

func _on_Key_Entry_selected(p_instance: FWDebugKeysEditorKeyEntry) -> void:
	if is_instance_valid(_a_key_entry):
		_a_key_entry.deselect()
	_select_entry(p_instance)

func _on_Key_Entry_pressed() -> void:
	_open()

func _on_Key_Entry_duplicate_pressed(p_instance: FWDebugKeysEditorKeyEntry) -> void:
	var data: Dictionary = p_instance.get_data()
	var key: String = p_instance.get_key()
	key += "_Dup"
	
	if _is_key_used(key):
		var messages: Messages = Debug.get_messages()
		messages.show_info(tr(&"FW_DEBUG_KEY_IN_USE"))
	else:
		_create_new_key_entry(key, data.duplicate(true))

func _on_Key_Entry_tree_exiting(p_instance: FWDebugKeysEditorKeyEntry) -> void:
	var key: StringName = p_instance.get_key()
	var idx: int = p_instance.get_index()
	p_instance.tree_exited.connect(_on_Key_Entry_tree_exited.bind(key, idx))

func _on_Key_Entry_tree_exited(p_key: StringName, p_idx: int) -> void:
	_a_keys_entries.erase(p_key)
	_update_data()
	_select_next_entry(p_idx)

func _on_Key_Entry_ready() -> void:
	_update_data.call_deferred()
	_sort_items.call_deferred()
