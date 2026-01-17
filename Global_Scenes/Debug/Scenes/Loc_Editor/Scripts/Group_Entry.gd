extends DebugEntryList
class_name DebugLocEditorGroupEntry

signal entry_select_focus_entered(p_instance: DebugLocEditorLocIDEntry)
signal entry_loc_id_changed(p_loc_id: StringName, p_instance: DebugLocEditorLocIDEntry)

@onready var _a_Expand: Button = get_node("Expand")
@onready var _a_HSep_1: HSeparator = get_node("HSep_1")
@onready var _a_HSep_2: HSeparator = get_node("HSep_2")

var _a_group: StringName
var _a_loc_id_type: StringName
var _a_loc_ids: Array[StringName] = []
var _a_expanded: bool = false

func _ready() -> void:
	super()
	_a_Expand.pressed.connect(_on_Expand_pressed)
	
	set_expanded(false)

func instantiate_entry_(p_loc_id: StringName) -> DebugLocEditorLocIDEntry:
	var instance: DebugLocEditorLocIDEntry = instantiate_entry(p_loc_id)
	instance.select_focus_entered.connect(_on_Entry_select_focus_entered.bind(instance))
	instance.loc_id_changed.connect(_on_Entry_loc_id_changed.bind(instance))
	instance.set_loc_id.call_deferred(p_loc_id)
	instance.update_display.call_deferred(_a_group, _a_loc_id_type)
	instance.update_visible_by_loc_id.call_deferred(_a_group, _a_loc_id_type)
	
	return instance

func update_entries() -> void:
	for loc_id: StringName in _a_entries:
		var instance: DebugLocEditorLocIDEntry = _a_entries[loc_id]
		instance.update_display(_a_group, _a_loc_id_type)
		instance.update_visible_by_loc_id(_a_group, _a_loc_id_type)

func grab_first_entry_focus() -> void:
	for child: DebugLocEditorLocIDEntry in _a_VBox.get_children():
		if child.is_visible():
			child.grab_select_focus()
			break

func grab_entry_focus(p_loc_id: StringName) -> void:
	var instance: DebugLocEditorLocIDEntry = _a_entries[p_loc_id]
	instance.grab_select_focus()

func add_loc_id(p_loc_id: StringName) -> void:
	_a_loc_ids.push_back(p_loc_id)
	if _a_expanded:
		var instance: DebugLocEditorLocIDEntry = instantiate_entry_(p_loc_id)
		add_entry(instance)

func remove_loc_id(p_loc_id: StringName) -> void:
	_a_loc_ids.erase(p_loc_id)
	if _a_expanded:
		var instance: DebugEntryListGroupEntry = _a_entries[p_loc_id]
		instance.queue_free()

func _instantiate_entries() -> void:
	for loc_id: StringName in _a_loc_ids:
		var instance: DebugLocEditorLocIDEntry = instantiate_entry_(loc_id)
		add_entry(instance)

func set_text(p_text: String) -> void:
	_a_Expand.set_text(p_text)

func set_group(p_group: StringName) -> void:
	_a_group = p_group

func set_loc_id_type(p_loc_id_type: StringName) -> void:
	_a_loc_id_type = p_loc_id_type
	update_entries.call_deferred()

func set_expanded(p_expanded: bool) -> void:
	_a_Search.set_visible(p_expanded && _e_show_search)
	_a_Scroll.set_visible(p_expanded)
	_a_HSep_1.set_visible(p_expanded)
	_a_HSep_2.set_visible(p_expanded)
	
	if p_expanded:
		_instantiate_entries()
	else:
		clear_entries()
	
	_a_expanded = p_expanded

func get_first_entry() -> DebugLocEditorLocIDEntry:
	for child: DebugLocEditorLocIDEntry in _a_VBox.get_children():
		if child.is_visible():
			return child
	
	return null

func get_loc_ids() -> Array[StringName]:
	return _a_loc_ids

func get_entry_(p_loc_id: StringName) -> DebugLocEditorLocIDEntry:
	return _a_entries[p_loc_id]

func get_entries_() -> Dictionary[String, DebugEntryListEntry]:
	return _a_entries

func _on_Expand_pressed() -> void:
	set_expanded(!_a_expanded)

func _on_Entry_select_focus_entered(p_instance: DebugLocEditorLocIDEntry) -> void:
	entry_select_focus_entered.emit(p_instance)

func _on_Entry_loc_id_changed(p_loc_id: String, p_instance: DebugLocEditorLocIDEntry) -> void:
	entry_loc_id_changed.emit(p_loc_id, p_instance)
