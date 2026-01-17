extends VBoxContainer
class_name DebugCommandEditorBranchBase

signal base_focus_entered()
signal base_focus_exited()
signal base_gui_input(p_event: InputEvent)
signal progress_focus_entered()
signal progress_gui_input(p_event: InputEvent)

const _a_FOCUS_COLOR: Color = Color.WHITE
const _a_NORMAL_COLOR: Color = Color.TRANSPARENT

var _a_Collapse_Image: Texture2D = preload("res://Global_Resources/Sprites/UI/Collapse.png")
var _a_Expand_Image: Texture2D = preload("res://Global_Resources/Sprites/UI/Expand.png")

@onready var _a_Base: MarginContainer = get_node("Base")
@onready var _a_Base_Outlines: Panel = get_node("Base/Outlines")
@onready var _a_Base_Margin: Control = get_node("Base/HBox/Margin")
@onready var _a_Base_Collapse: TextureButton = get_node("Base/HBox/Collapse")
@onready var _a_Base_Desc: Label = get_node("Base/HBox/Desc")
@onready var _a_Process: MarginContainer = get_node("Process")
@onready var _a_Process_Outlines: Panel = get_node("Process/Outlines")
@onready var _a_Process_Margin: Control = get_node("Process/HBox/Margin")
@onready var _a_Entries: VBoxContainer = get_node("Entries")

func _ready() -> void:
	_a_Base.focus_entered.connect(_on_Base_focus_entered)
	_a_Base.focus_exited.connect(_on_Base_focus_exited)
	_a_Base.gui_input.connect(_on_Base_gui_input)
	_a_Base_Collapse.pressed.connect(_on_Base_Collapse_pressed)
	_a_Process.focus_entered.connect(_on_Process_focus_entered)
	_a_Process.focus_exited.connect(_on_Process_focus_exited)
	_a_Process.gui_input.connect(_on_Process_gui_input)
	
	_a_Base_Collapse.hide()
	_a_Process.hide()

func grab_base_focus() -> void:
	_a_Base.grab_focus()

func release_base_focus() -> void:
	_a_Base.release_focus()

func set_collapse_visible(p_visible: bool) -> void:
	_a_Base_Collapse.set_visible(p_visible)

func set_collapsed(p_collapsed: bool) -> void:
	_a_Entries.set_visible(!p_collapsed)
	if p_collapsed:
		_a_Base_Collapse.set_texture_normal(_a_Expand_Image)
	else:
		_a_Base_Collapse.set_texture_normal(_a_Collapse_Image)

func set_process_visible(p_visible: bool) -> void:
	_a_Process.set_visible(p_visible)

func has_base_focus() -> bool:
	return _a_Base.has_focus()

func set_base_focus_mode(p_focus_mode: FocusMode) -> void:
	_a_Base.set_focus_mode(p_focus_mode)

func set_base_modulate(p_color: Color) -> void:
	_a_Base.set_modulate(p_color)

func set_base_desc(p_desc: String) -> void:
	_a_Base_Desc.set_text(p_desc)

func set_base_desc_modulate(p_color: Color) -> void:
	_a_Base_Desc.set_modulate(p_color)

func get_entries_instance() -> VBoxContainer:
	return _a_Entries

func set_base_margin_min_size(p_size: Vector2) -> void:
	_a_Base_Margin.set_custom_minimum_size(p_size)

func get_base_margin_min_size() -> Vector2:
	return _a_Base_Margin.get_custom_minimum_size()

func get_base_desc_position() -> Vector2:
	return _a_Base_Desc.get_position()

func get_process_instance() -> MarginContainer:
	return _a_Process

func get_process_margin_instance() -> Control:
	return _a_Process_Margin

func get_base_desc_size() -> Vector2:
	return _a_Base_Desc.get_size()

func get_entries() -> Array[Node]:
	return _a_Entries.get_children()

func get_entry(p_idx: int) -> DebugCommandEditorEntryBase:
	return _a_Entries.get_child(p_idx)

func get_cutscene_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for child: DebugCommandEditorEntryBase in _a_Entries.get_children():
		if !child.is_empty():
			var entry_data: Dictionary = child.get_cutscene_data()
			data.push_back(entry_data)
	
	return data

func get_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Collapsed"] = !_a_Entries.is_visible()
	
	data[&"Entries"] = []
	for child: DebugCommandEditorEntryBase in _a_Entries.get_children():
		if !child.is_empty():
			var command: StringName = child.get_command()
			var child_data: Dictionary = child.get_editor_data()
			child_data[&"Command"] = command
			data[&"Entries"].push_back(child_data)
	
	return data

func _on_Base_focus_entered() -> void:
	_a_Base_Outlines.set_self_modulate(_a_FOCUS_COLOR)
	base_focus_entered.emit()

func _on_Base_focus_exited() -> void:
	_a_Base_Outlines.set_self_modulate(_a_NORMAL_COLOR)
	base_focus_exited.emit()

func _on_Base_gui_input(p_event: InputEvent) -> void:
	base_gui_input.emit(p_event)

func _on_Base_Collapse_pressed() -> void:
	var collapsed: bool = _a_Entries.is_visible()
	set_collapsed(collapsed)

func _on_Process_focus_entered() -> void:
	_a_Process_Outlines.set_self_modulate(_a_FOCUS_COLOR)
	progress_focus_entered.emit()

func _on_Process_focus_exited() -> void:
	_a_Process_Outlines.set_self_modulate(_a_NORMAL_COLOR)

func _on_Process_gui_input(p_event: InputEvent) -> void:
	progress_gui_input.emit(p_event)
