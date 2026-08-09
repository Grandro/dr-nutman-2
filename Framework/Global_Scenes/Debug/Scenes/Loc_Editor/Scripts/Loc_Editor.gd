extends MarginContainer
class_name FWDebugLocEditor

signal loc_id_selected(p_loc_id: StringName)
signal trans_changed()
signal closed()

var _a_Trans_Entry_Scene: PackedScene = preload("uid://b201uw08dpcly")
var _a_Group_Entry_Scene: PackedScene = preload("uid://celfgly0nsc5h")

@export_enum("Select", "Edit") var _e_mode: String = "Select"
@export_enum("Global", "Map") var _e_loc_id_type: String = "Global"
@export var _e_show_return: bool = true

const _a_KEYS_TYPE_LOC_ID: String = "FW_DEBUG_TYPE_%s"

@onready var _a_Loc_ID_Types: FWKeyEntryToggler = get_node("Margin/VBox/Up/Loc_ID_Types")
@onready var _a_Save: Button = get_node("Margin/VBox/Up/Options/Save")
@onready var _a_Back: Button = get_node("Margin/VBox/Up/Options/Back")
@onready var _a_Trans_Entries: FWEntryToggler = get_node("Margin/VBox/Trans_Entries")
@onready var _a_Groups_Scroll: ScrollContainer = get_node("Margin/VBox/Down/Groups/Scroll")
@onready var _a_Groups: FWAnimVBox = get_node("Margin/VBox/Down/Groups/Scroll/VBox")
@onready var _a_Add: VBoxContainer = get_node("Margin/VBox/Down/Groups/Add")
@onready var _a_Add_Input: LineEdit = get_node("Margin/VBox/Down/Groups/Add/Input")
@onready var _a_Add_Select: Button = get_node("Margin/VBox/Down/Groups/Add/Select")
@onready var _a_Select: Button = get_node("Margin/VBox/Down/Groups/Select")
@onready var _a_Loc_ID: Label = get_node("Margin/VBox/Down/Trans/Margin/Entries/Loc_ID")
@onready var _a_Heading: RichTextLabel = get_node("Margin/VBox/Down/Trans/Margin/Entries/VBox/Heading")
@onready var _a_Trans: VBoxContainer = get_node("Margin/VBox/Down/Trans/Margin/Entries/VBox/Scroll/VBox")

var _a_loc_id: StringName # loc_id of currently focused Loc_ID_Entry
var _a_group_entries: Dictionary[StringName, FWDebugLocEditorGroupEntry] = {} # Match group to instance
var _a_trans: Dictionary = {} # Match prefix to locale to Translation
var _a_trans_prefix: Dictionary[FWEntryTogglerEntry, String] # Match trans_entry to prefix
var _a_prefix: String # prefix of current trans_entry

func _ready() -> void:
	_a_Loc_ID_Types.toggled.connect(_on_Loc_ID_Types_toggled)
	_a_Save.pressed.connect(_on_Save_pressed)
	_a_Back.pressed.connect(_on_Back_pressed)
	_a_Trans_Entries.toggled.connect(_on_Trans_Entries_toggled)
	_a_Add_Select.pressed.connect(_on_Add_Select_pressed)
	_a_Select.pressed.connect(_on_Select_pressed)
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)
	Debug.loc_data_loaded.connect(_on_Debug_loc_data_loaded)
	
	_a_Loc_ID.set_message_translation(false)
	_a_Heading.set_text("[u]%s" % tr(&"FW_DEBUG_TRANS"))
	
	set_mode(_e_mode)
	_create_loc_id_types()
	
	if !_e_show_return:
		_a_Back.hide()
	hide()

func update_trans() -> void:
	_a_Heading.set_text("[u]%s" % tr(&"FW_DEBUG_TRANS"))

func open(p_group: StringName = &"", p_loc_id: StringName = &"") -> void:
	_update_groups()
	show()
	
	if !p_loc_id.is_empty():
		p_group = _get_group(p_loc_id)
	
	if !p_group.is_empty() && _a_group_entries.has(p_group):
		var group_instance: FWDebugLocEditorGroupEntry = _a_group_entries[p_group]
		group_instance.set_expanded(true)
		
		var group_loc_ids: Array[StringName] = group_instance.get_loc_ids()
		var loc_id_instance: FWDebugLocEditorLocIDEntry
		if !p_loc_id.is_empty() && group_loc_ids.has(p_loc_id):
			loc_id_instance = group_instance.get_entry_(p_loc_id)
		else:
			loc_id_instance = group_instance.get_first_entry()
		
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		loc_id_instance.grab_select_focus()
		_a_Groups_Scroll.ensure_control_visible(loc_id_instance)

func close() -> void:
	_clear_groups()
	
	closed.emit()
	hide()

func toggle_loc_id_types(p_loc_id_type: StringName) -> void:
	_a_Loc_ID_Types.toggle(p_loc_id_type)

func _clear_groups() -> void:
	_a_group_entries.clear()
	for child: FWDebugLocEditorGroupEntry in _a_Groups.get_children():
		child.queue_free()

func _create_loc_id_types() -> void:
	for loc_id_type: String in ["Map", "Global"]:
		var select_text: String = tr(_a_KEYS_TYPE_LOC_ID % loc_id_type.to_upper())
		var instance: FWEntryTogglerKeyEntry = _a_Loc_ID_Types.instantiate_entry_(select_text, null, loc_id_type)
		_a_Loc_ID_Types.add_entry(instance)

func _create_trans_entries() -> void:
	var translations: Array[Translation] = TranslationServer.get_translations()
	for translation: Translation in translations:
		var path: String = translation.get_path()
		var first_dot_idx: int = path.find(".")
		var second_dot_idx: int = path.rfind(".")
		var prefix: String = path.left(first_dot_idx)
		var locale: String = path.substr(first_dot_idx + 1, second_dot_idx - first_dot_idx - 1)
		if !_a_trans.has(prefix):
			_a_trans[prefix] = {}
		_a_trans[prefix][locale] = translation
	
	for prefix: String in _a_trans:
		var instance: FWEntryTogglerEntry = _a_Trans_Entries.instantiate_entry(prefix)
		instance.set_select_tooltip_text.call_deferred(prefix)
		_a_trans_prefix[instance] = prefix
		_a_Trans_Entries.add_entry(instance)

func _instantiate_group(p_group: StringName) -> FWDebugLocEditorGroupEntry:
	var instance: FWDebugLocEditorGroupEntry = _a_Group_Entry_Scene.instantiate()
	instance.entry_deleting.connect(_on_Group_Entry_entry_deleting.bind(p_group))
	instance.entry_select_focus_entered.connect(_on_Group_Entry_entry_select_focus_entered)
	instance.entry_loc_id_changed.connect(_on_Group_Entry_entry_loc_id_changed.bind(p_group))
	instance.set_text.call_deferred(p_group)
	instance.set_group(p_group)
	instance.set_loc_id_type(_e_loc_id_type)
	
	_a_group_entries[p_group] = instance
	
	return instance

func _update_groups() -> void:
	_clear_groups()
	
	for loc_id: StringName in Debug.get_loc_data(_a_prefix):
		var group: StringName = _get_group(loc_id)
		var instance: FWDebugLocEditorGroupEntry = _get_or_create_group_instance(group)
		instance.add_loc_id(loc_id)

func _clear_trans() -> void:
	_a_Loc_ID.set_text("-")
	for child: FWDebugLocEditorTransEntry in _a_Trans.get_children():
		child.queue_free()

func _update_trans(p_instance: FWDebugLocEditorLocIDEntry) -> void:
	_clear_trans()
	
	var loc_data: Dictionary = Debug.get_loc_data(_a_prefix)
	var loc_id: StringName = p_instance.get_loc_id()
	var data: Dictionary = loc_data[loc_id]
	for locale: StringName in data:
		var text: String = data[locale]
		var instance: FWDebugLocEditorTransEntry = _a_Trans_Entry_Scene.instantiate()
		instance.text_changed.connect(_on_Trans_Entry_text_changed.bind(p_instance, locale))
		instance.set_heading.call_deferred(locale)
		instance.set_text.call_deferred(text)
		if _e_mode == &"Select":
			instance.set_text_editable.call_deferred(false)
		
		_a_Trans.add_child(instance)
	
	_a_Loc_ID.set_text(loc_id)

func _remove_loc_id(p_prefix: String, p_group: StringName, p_loc_id: StringName) -> void:
	var group_instance: FWDebugLocEditorGroupEntry = _a_group_entries[p_group]
	group_instance.remove_loc_id(p_loc_id)
	Debug.erase_loc_id(p_prefix, p_loc_id)
	
	var group_loc_ids: Array[StringName] = group_instance.get_loc_ids()
	if group_loc_ids.is_empty():
		group_instance.queue_free()
		_a_group_entries.erase(p_group)
		
		_clear_trans()

func set_mode(p_mode: StringName) -> void:
	match p_mode:
		&"Select":
			_a_Save.hide()
			_a_Add.hide()
			_a_Select.show()
		&"Edit":
			_a_Save.show()
			_a_Add.show()
			_a_Select.hide()
	
	_e_mode = p_mode

func _get_group(p_loc_id: String) -> String:
	var group: String = "_Misc"
	var sep_idx: int = p_loc_id.find("_")
	if sep_idx != -1:
		var prefix: String = p_loc_id.substr(0, sep_idx)
		group = prefix.capitalize()
	
	return group

func _get_used_loc_ids(p_prefix: String) -> Array[StringName]:
	var loc_data: Dictionary = Debug.get_loc_data(p_prefix)
	var loc_ids: Array[StringName] = loc_data.keys()
	
	return loc_ids

func _get_or_create_group_instance(p_group: StringName) -> FWDebugLocEditorGroupEntry:
	var instance: FWDebugLocEditorGroupEntry
	if _a_group_entries.has(p_group):
		instance = _a_group_entries[p_group]
	else:
		instance = _instantiate_group(p_group)
		_a_Groups.add_child(instance)
	
	return instance

func _on_Loc_ID_Types_toggled(p_instance: FWEntryTogglerKeyEntry) -> void:
	_e_loc_id_type = p_instance.get_key()
	for group: StringName in _a_group_entries:
		var group_instance: FWDebugLocEditorGroupEntry = _a_group_entries[group]
		group_instance.set_loc_id_type(_e_loc_id_type)

func _on_Trans_Entries_toggled(p_instance: FWEntryTogglerEntry) -> void:
	_a_prefix = _a_trans_prefix[p_instance]
	_update_groups()

func _on_Save_pressed() -> void:
	var loc_ids: Array[StringName] = []
	for child: FWDebugLocEditorGroupEntry in _a_Groups.get_children():
		var child_loc_ids: Array[StringName] = child.get_loc_ids()
		loc_ids.append_array(child_loc_ids)
	Data_Parser.write_loc_data(_a_prefix, loc_ids)

func _on_Back_pressed() -> void:
	close()

func _on_Add_Select_pressed() -> void:
	var loc_id: StringName = _a_Add_Input.get_text()
	if loc_id == &"":
		return
	
	var used_loc_ids: Array[StringName] = _get_used_loc_ids(_a_prefix)
	if used_loc_ids.has(loc_id):
		return
	
	_a_Add_Input.clear()
	
	var locales: PackedStringArray = TranslationServer.get_loaded_locales()
	for locale: String in locales:
		var trans: Translation = _a_trans[_a_prefix][locale]
		trans.add_message(loc_id, "")
	Debug.add_loc_id(_a_prefix, loc_id)
	
	var group: String = _get_group(loc_id)
	var group_instance = _get_or_create_group_instance(group)
	group_instance.add_loc_id(loc_id)

func _on_Select_pressed() -> void:
	loc_id_selected.emit(_a_loc_id)
	close()

func _on_Scene_Manager_scene_changed(_p_instance: Node, _p_loaded_file_data: bool) -> void:
	if Scene_Manager.is_curr_scene_map_encounter():
		toggle_loc_id_types(&"Map")
	else:
		toggle_loc_id_types(&"Global")

func _on_Debug_loc_data_loaded() -> void:
	_create_trans_entries()

func _on_Group_Entry_entry_select_focus_entered(p_instance: FWDebugLocEditorLocIDEntry) -> void:
	_update_trans(p_instance)
	_a_loc_id = p_instance.get_loc_id()

func _on_Group_Entry_entry_loc_id_changed(p_loc_id: StringName, p_instance: FWDebugLocEditorLocIDEntry, p_old_group: StringName) -> void:
	p_instance.set_input_text("")
	
	var loc_id: StringName = p_instance.get_loc_id()
	if p_loc_id == &"" || loc_id == p_loc_id:
		return
	
	var used_loc_ids: Array[StringName] = _get_used_loc_ids(_a_prefix)
	if used_loc_ids.has(p_loc_id):
		return
	
	var loc_data: Dictionary = Debug.get_loc_data(_a_prefix)
	var new_group: StringName = _get_group(p_loc_id)
	
	var locales: Array[StringName] = loc_data[loc_id].keys()
	for locale: StringName in locales:
		var trans: Translation = _a_trans[_a_prefix][locale]
		trans.erase_message(loc_id)
		trans.add_message(p_loc_id, loc_data[loc_id][locale])
	
	Debug.add_loc_id(p_loc_id, loc_data[loc_id])
	trans_changed.emit()
	
	var new_group_instance: FWDebugLocEditorGroupEntry = _get_or_create_group_instance(new_group)
	new_group_instance.add_loc_id(p_loc_id)
	_remove_loc_id(_a_prefix, p_old_group, loc_id)

func _on_Group_Entry_entry_deleting(p_instance: FWDebugLocEditorLocIDEntry, p_group: StringName) -> void:
	var loc_id: StringName = p_instance.get_loc_id()
	for trans: Translation in _a_trans[_a_prefix].values():
		trans.erase_message(loc_id)
	trans_changed.emit()
	
	_remove_loc_id(_a_prefix, p_group, loc_id)

func _on_Trans_Entry_text_changed(p_text: StringName, p_instance: FWDebugLocEditorLocIDEntry, p_locale: StringName) -> void:
	var loc_id: StringName = p_instance.get_loc_id()
	var trans: Translation = _a_trans[_a_prefix][p_locale]
	trans.erase_message(loc_id)
	trans.add_message(loc_id, p_text)
	trans_changed.emit()
	
	var loc_data: Dictionary = Debug.get_loc_data(_a_prefix)
	loc_data[loc_id][p_locale] = p_text
