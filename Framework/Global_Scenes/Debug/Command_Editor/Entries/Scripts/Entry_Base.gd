extends MarginContainer
class_name FWDebugCommandEditorEntryBase

signal activated()
signal selectable_focus_entered()
signal selectable_left_clicked()
signal selectable_right_clicked(p_pos: Vector2)

const _a_FOCUS_COLOR: Color = Color.WHITE
const _a_NORMAL_COLOR: Color = Color(1.0, 1.0, 1.0, 0.0)
const _a_DISABLED_COLOR: Color = Color(0.78, 0.78, 0.78, 1.0)
const _a_ENABLED_COLOR: Color = Color.WHITE

@onready var _a_Highlight: Panel = get_node("Highlight")
@onready var _a_Branches: VBoxContainer = get_node("HBox/VBox/Branches")
@onready var _a_Main: FWDebugCommandEditorBranchMain = get_node("HBox/VBox/Branches/Main")

var _a_parents: Array[FWDebugCommandEditorEntryBase] = [] # Every entry parent of this entry
var _a_branch_idx: int = 0 # Branch index of parent entry

var _a_command: StringName = &""
var _a_fake_focus: bool = false
var _a_disabled: bool = false

func _ready() -> void:
	_a_Main.base_focus_entered.connect(_on_Main_base_focus_entered)
	_a_Main.base_focus_exited.connect(_on_Main_base_focus_exited)
	_a_Main.base_gui_input.connect(_on_Main_base_gui_input)

func connect_to_editor(p_editor: FWDebugCommandEditor) -> void:
	activated.connect(p_editor._on_Entry_activated)
	selectable_focus_entered.connect(p_editor._on_Entry_selectable_focus_entered.bind(self))
	selectable_left_clicked.connect(p_editor._on_Entry_selectable_left_clicked.bind(self))
	selectable_right_clicked.connect(p_editor._on_Entry_selectable_right_clicked.bind(self))

func add_res_data(_p_res_data: Dictionary, _p_args: Array = []) -> void:
	pass

func grab_main_base_focus() -> void:
	_a_Main.grab_base_focus()

func release_main_base_focus() -> void:
	_a_Main.release_base_focus()

func set_disabled(p_disabled: bool) -> void:
	if p_disabled:
		_a_Main.set_base_focus_mode(Control.FOCUS_NONE)
		_a_Main.set_base_modulate(_a_DISABLED_COLOR)
		set_fake_focus(false)
	else:
		_a_Main.set_base_focus_mode(Control.FOCUS_ALL)
		_a_Main.set_base_modulate(_a_ENABLED_COLOR)
	
	_a_disabled = p_disabled

func set_process_visible(p_branch_idx: int, p_visible: bool) -> void:
	var instance: FWDebugCommandEditorBranchBase = _a_Branches.get_child(p_branch_idx)
	instance.set_process_visible(p_visible)

func set_fake_focus(p_fake_focus: bool) -> void:
	_a_fake_focus = p_fake_focus
	
	if p_fake_focus:
		_a_Highlight.set_self_modulate(_a_FOCUS_COLOR)
		return
	
	if _a_Main.has_base_focus():
		_a_Highlight.set_self_modulate(_a_FOCUS_COLOR)
	else:
		_a_Highlight.set_self_modulate(_a_NORMAL_COLOR)

func set_branches_margin(p_margin: float) -> void:
	for child: FWDebugCommandEditorBranchBase in _a_Branches.get_children():
		var min_size: Vector2 = child.get_base_margin_min_size()
		child.set_base_margin_min_size(Vector2(p_margin, min_size.y))

func get_branches_margin() -> float:
	# Every branch has the same margin -> Get margin of Main
	return _a_Main.get_base_margin_min_size().x

func get_branch_idxs() -> Array[int]:
	var idxs: Array[int] = []
	for parent: FWDebugCommandEditorEntryBase in _a_parents:
		var idx: int = parent.get_branch_idx()
		idxs.push_back(idx)
	idxs.push_back(_a_branch_idx)
	
	return idxs

func get_used_branches_idxs() -> Array[int]:
	var used: Array[int] = []
	for i: int in _a_Branches.get_child_count():
		if _is_branch_used(i):
			used.push_back(i)
	
	return used

func is_empty() -> bool:
	return _a_command == &""

func set_parents(p_parents: Array[FWDebugCommandEditorEntryBase]) -> void:
	_a_parents = p_parents

func get_parents() -> Array[FWDebugCommandEditorEntryBase]:
	return _a_parents

func set_branch_idx(p_branch_idx: int) -> void:
	_a_branch_idx = p_branch_idx

func get_branch_idx() -> int:
	return _a_branch_idx

func set_command(p_command: StringName) -> void:
	_a_command = p_command

func get_command() -> StringName:
	return _a_command

func _is_branch_used(p_branch_idx: int) -> bool:
	var instance: FWDebugCommandEditorBranchBase = _a_Branches.get_child(p_branch_idx)
	var entries: Array[Node] = instance.get_entries()
	return instance.is_visible() && !entries.is_empty()

func _get_var_display_text(p_data: Dictionary) -> String:
	var expr_data: Dictionary = p_data[&"Expression"]
	var expr_type: StringName = expr_data[&"Type"]
	var text: String = expr_data[&"Instance_Key"]
	if expr_type == &"Object":
		text += ":%s" % expr_data[&"Comp"]
	text += ":%s" % expr_data[&"Expression"]
	
	return text

func _on_Main_base_focus_entered() -> void:
	if !_a_fake_focus:
		_a_Highlight.set_self_modulate(_a_FOCUS_COLOR)
	
	selectable_focus_entered.emit()

func _on_Main_base_focus_exited() -> void:
	if !_a_fake_focus:
		_a_Highlight.set_self_modulate(_a_NORMAL_COLOR)

func _on_Main_base_gui_input(p_event: InputEvent) -> void:
	if _a_disabled:
		return
	
	if p_event.is_action_pressed(&"Mouse_Left"):
		selectable_left_clicked.emit()
		if p_event.is_double_click():
			activated.emit()
	
	elif p_event.is_action_pressed(&"Mouse_Right"):
		var pos: Vector2 = get_global_mouse_position()
		selectable_right_clicked.emit(pos)
