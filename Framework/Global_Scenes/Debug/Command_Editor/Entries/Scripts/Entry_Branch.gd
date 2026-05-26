extends FWDebugCommandEditorEntryCommand
class_name FWDebugCommandEditorEntryBranch

signal unselectable_focus_entered()
signal unselectable_right_clicked(p_pos: Vector2)
signal request_empty_entry(p_idx: int, p_margin: float, p_entries: VBoxContainer)
signal request_command_entry(p_command: StringName, p_entry_data: Dictionary, p_idx: int, p_margin: float, p_entries: VBoxContainer)

@export var _e_start_branch_idx: int = 0

@onready var _a_End: FWDebugCommandEditorArgEntry = get_node("HBox/VBox/End")

var _a_process_branch_idx: int = -1

func _ready() -> void:
	super()
	_a_End.focus_entered.connect(_on_Unselectable_focus_entered)
	_a_End.gui_input.connect(_on_Unselectable_gui_input)
	
	_a_End.set_desc(tr(&"DEBUG_CUTSCENES_END"))

func connect_to_editor(p_editor: FWDebugCommandEditor) -> void:
	super(p_editor)
	unselectable_focus_entered.connect(p_editor._on_Entry_unselectable_focus_entered)
	unselectable_right_clicked.connect(p_editor._on_Entry_unselectable_right_clicked)
	request_empty_entry.connect(p_editor._on_Entry_request_empty_entry.bind(self))
	request_command_entry.connect(p_editor._on_Entry_request_command_entry.bind(self))

func add_res_data(p_res_data: Dictionary, p_args: Array = []) -> void:
	var branch_idx: int = _a_process_branch_idx
	var end_idx: int = -1
	if !p_args.is_empty():
		branch_idx = p_args[0]
		end_idx = p_args[1]
	
	var entries: Array[FWDebugCommandEditorEntryBase] = get_entries(branch_idx)
	for i: int in entries.size():
		if i == end_idx:
			break
		
		var entry: FWDebugCommandEditorEntryBase = entries[i]
		entry.add_res_data(p_res_data)

func update_data(p_data: Dictionary) -> void:
	var is_empty_: bool = _a_data.is_empty()
	super(p_data)
	
	if is_empty_:
		_init_branches()
	_update_branches()

func swap_process(p_branch_idx: int) -> void:
	if _a_process_branch_idx != -1:
		set_process_visible(_a_process_branch_idx, false)
	
	set_process_visible(p_branch_idx, true)
	_a_process_branch_idx = p_branch_idx

func swap_process_next() -> void:
	var child_amount: int = _a_Branches.get_child_count()
	var next_branch_idx: int = (_a_process_branch_idx + 1) % child_amount
	swap_process(next_branch_idx)

func update_display() -> void:
	super()
	_a_End.set_desc_modulate(_e_color)

func _init_branches() -> void:
	var margin: float = _get_main_arg_margin()
	var branches: Dictionary = _a_args[&"Branches"]
	if branches.is_empty():
		_init_branches_new(margin)
	else:
		_init_branches_data(branches, margin)
	
	var process_branch_idx: int = _a_args[&"Process_Branch_Idx"]
	swap_process(process_branch_idx)

func _init_branches_new(p_margin: float) -> void:
	var child_count: int = _a_Branches.get_child_count()
	for i: int in range(_e_start_branch_idx, child_count):
		var child: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i)
		var entries: VBoxContainer = child.get_entries_instance()
		request_empty_entry.emit(i, p_margin, entries)

func _init_branches_data(p_data: Dictionary, p_margin: float) -> void:
	var child_count: int = _a_Branches.get_child_count()
	for i: int in range(_e_start_branch_idx, child_count):
		var branch: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i)
		var entries: VBoxContainer = branch.get_entries_instance()
		
		if p_data.has(i):
			var entries_data: Array[Dictionary]; entries_data.assign(p_data[i][&"Entries"])
			for entry_data: Dictionary in entries_data:
				var command: StringName = entry_data[&"Command"]
				request_command_entry.emit(command, entry_data, i, p_margin, entries)
		
		if i > 0:
			# Main Branch doesnt need margin/show
			var base_min_size: Vector2 = branch.get_base_margin_min_size()
			var desc_pos: Vector2 = _a_Main.get_base_desc_position() / 2
			branch.set_base_margin_min_size(Vector2(desc_pos.x, base_min_size.y))
			branch.show()
		
		request_empty_entry.emit(i, p_margin, entries)
	
	for branch_idx: int in _a_args[&"Branches"]:
		var collapsed: bool = _a_args[&"Branches"][branch_idx][&"Collapsed"]
		_set_collapsed(branch_idx, collapsed)

func _update_branches() -> void:
	pass

func set_args(p_args: Dictionary) -> void:
	super(p_args)
	if !_a_args.has(&"Branches"):
		_a_args[&"Branches"] = {}
	if !_a_args.has(&"Process_Branch_Idx"):
		_a_args[&"Process_Branch_Idx"] = 0

func _set_collapsed(p_branch_idx: int, p_collapsed: bool) -> void:
	var branch: FWDebugCommandEditorBranchBase = _a_Branches.get_child(p_branch_idx)
	branch.set_collapsed(p_collapsed)

func get_cutscene_data() -> Array[Dictionary]:
	var branch: FWDebugCommandEditorBranchBase = _a_Branches.get_child(_a_process_branch_idx)
	return branch.get_cutscene_data()

func get_save_data() -> Dictionary:
	_a_args[&"Branches"].clear()
	var idxs: Array[int] = get_used_branches_idxs()
	for i: int in idxs:
		var child: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i)
		_a_args[&"Branches"][i] = child.get_data()
	_a_args[&"Process_Branch_Idx"] = _a_process_branch_idx
	
	return super()

func _on_Unselectable_focus_entered() -> void:
	unselectable_focus_entered.emit()

func _on_Unselectable_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Mouse_Right"):
		var pos: Vector2 = p_event.get_global_position()
		unselectable_right_clicked.emit(pos)
