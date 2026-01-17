extends VBoxContainer
class_name DebugStaterAttributes

const _a_TYPES_LOC_ID: String = "DEBUG_STATER_%s"

@onready var _a_Types: KeyEntryToggler = get_node("Types")
@onready var _a_Conditions: DebugExpressionEntryList = get_node("Conditions")
@onready var _a_Actions: DebugActionEntryList = get_node("Actions")
@onready var _a_Preview: DebugCommandsPreview = get_node("Preview")

var _a_key: StringName # Key_Entry key
var _a_action_entry: DebugEntryListActionEntry = null

func _ready() -> void:
	_a_Types.toggled.connect(_on_Types_toggled)
	_a_Actions.entry_option_test_selected.connect(_on_Actions_entry_option_test_selected)
	_a_Actions.entry_selectable_focus_entered.connect(_on_Actions_entry_selectable_focus_entered)
	_a_Actions.entry_preview_pressed.connect(_on_Actions_entry_preview_pressed)
	
	_create_types()

func open(p_data: Dictionary) -> void:
	for type: StringName in p_data:
		var instance: DebugEntryList = _get_entry_list(type)
		instance.load_data(p_data[type])

func close() -> void:
	_a_Conditions.clear_entries()
	_a_Actions.clear_entries()

func action_set_editor_active(p_active: bool) -> void:
	if is_instance_valid(_a_action_entry):
		_a_action_entry.set_editor_active(p_active)

func _create_types() -> void:
	for type: String in ["Conditions", "Actions"]:
		var select_text: String = tr(_a_TYPES_LOC_ID % type.to_upper())
		var instance: EntryTogglerKeyEntry = _a_Types.instantiate_entry_(select_text, null, type)
		_a_Types.add_entry(instance)

func _instantiate_condition(p_data: Dictionary = {}) -> void:
	var instance: DebugEntryListExpressionEntry = _a_Conditions.instantiate_entry_(p_data, _a_key)
	_a_Conditions.add_entry(instance)

func _instantiate_action(p_data: Array[Dictionary] = []) -> void:
	var instance: DebugEntryListActionEntry = _a_Actions.instantiate_entry_(p_data)
	_a_Actions.add_entry(instance)

func _get_entry_list(p_type: StringName) -> DebugEntryList:
	match p_type:
		&"Conditions": return _a_Conditions
		&"Actions": return _a_Actions
	
	return null

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	for type: StringName in [&"Conditions", &"Actions"]:
		var entry_list: DebugEntryList = _get_entry_list(type)
		data[type] = entry_list.get_save_data()
	
	return data

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func _on_Types_toggled(p_instance: EntryTogglerKeyEntry) -> void:
	var type: StringName = p_instance.get_key()
	_a_Conditions.set_visible(type == &"Conditions")
	_a_Actions.set_visible(type == &"Actions")

func _on_Actions_entry_option_test_selected(p_cutscene_data: Array[Dictionary], p_skip_idxs: Array[int]) -> void:
	_a_Preview.open(p_cutscene_data, p_skip_idxs)

func _on_Actions_entry_selectable_focus_entered(p_instance: DebugEntryListActionEntry) -> void:
	if p_instance == _a_action_entry:
		return
	if is_instance_valid(_a_action_entry):
		_a_action_entry.set_editor_active(false)
	
	p_instance.set_editor_active(true)
	_a_action_entry = p_instance

func _on_Actions_entry_preview_pressed(p_cutscene_data: Array[Dictionary]) -> void:
	_a_Preview.open(p_cutscene_data, [])
