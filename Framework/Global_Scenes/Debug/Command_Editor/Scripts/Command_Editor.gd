extends HBoxContainer
class_name FWDebugCommandEditor

signal option_test_selected(p_instance: FWDebugCommandEditorEntryBase)
signal selectable_focus_entered()

@export var _e_edit_scene_uids: Dictionary = {} # [Command][Dim] = uid

var _a_Entry_Base_Scene: PackedScene = preload("uid://bc28ss3fdbnss")

const _a_ENTRY_PATH: String = "res://Framework/Global_Scenes/Debug/Command_Editor/Entries/%s/%s.tscn"

@onready var _a_Entries: FWDebugCommandEditorEntries = get_node("Contents/Panel/Entries")
@onready var _a_Options: FWContextMenu = get_node("Contents/Panel/Options")
@onready var _a_Warnings: FWDebugCommandEditorWarnings = get_node("Contents/Panel/Warnings")

var _a_undo_redo: UndoRedo = UndoRedo.new()
var _a_active: bool = false # Is currently active?
var _a_new_option: bool = false # Commands_List openend to create a new entry?
var _a_selected: Array[FWDebugCommandEditorEntryBase] = [] # Selected entries 
var _a_first: FWDebugCommandEditorEntryBase = null # First selected entry
var _a_last_focused: FWDebugCommandEditorEntryBase = null # Last focused entry
var _a_test_entry: FWDebugCommandEditorEntryBase = null # test mark entry

func _ready() -> void:
	_a_Options.option_selected.connect(_on_Options_option_selected)
	_a_undo_redo.version_changed.connect(_on_Undo_Redo_version_changed)
	Debug.closing.connect(_on_Debug_closing)
	
	_a_Options.set_options_disabled([&"Undo", &"Redo", &"Paste"], true)
	set_process_unhandled_input(false)

func _unhandled_input(p_event: InputEvent) -> void:
	if _a_Options.is_visible():
		return
	
	if p_event.is_action_pressed(&"Redo"):
		_option_redo()
	elif p_event.is_action_pressed(&"Undo"):
		_option_undo()
	elif p_event.is_action_pressed(&"Space"):
		_option_edit()
	elif p_event.is_action_pressed(&"Cut"):
		_option_cut()
	elif p_event.is_action_pressed(&"Copy"):
		_option_copy()
	elif p_event.is_action_pressed(&"Paste"):
		_option_paste()
	elif p_event.is_action_pressed(&"Delete"):
		_option_delete()
	elif p_event.is_action_pressed(&"Select_All"):
		_option_select_all()
	elif p_event.is_action_pressed(&"Test"):
		_option_test()
	elif p_event.is_action_pressed(&"Swap_Process"):
		_option_swap_process()
	elif p_event.is_action_pressed(&"Shift_Up"):
		_shift_arrows(-1)
	elif p_event.is_action_pressed(&"Shift_Down"):
		_shift_arrows(1)

func update_entries(p_data: Array[Dictionary]) -> void:
	clear_entries()
	
	var last: FWDebugCommandEditorEntryBase = _instantiate_empty_entry()
	_a_Entries.add_child(last)
	
	for data: Dictionary in p_data:
		var command: StringName = data[&"Command"]
		var entry_data: Dictionary = data[&"Data"].duplicate(true)
		var entry_args: Dictionary = data[&"Args"].duplicate(true)
		_instantiate_command_entry_add(command, entry_data, entry_args)

func clear_entries() -> void:
	clear_selected()
	for child: FWDebugCommandEditorEntryBase in _a_Entries.get_children():
		child.queue_free()

func clear_selected() -> void:
	for selected: FWDebugCommandEditorEntryBase in _a_selected:
		selected.set_fake_focus(false)
		selected.release_main_base_focus()
	_a_selected.clear()

func disable_last_entry() -> void:
	var last: FWDebugCommandEditorEntryBase = _a_Entries.get_child(-1)
	last.disable()

func _instantiate_empty_entry() -> FWDebugCommandEditorEntryBase:
	var instance: FWDebugCommandEditorEntryBase = _a_Entry_Base_Scene.instantiate()
	instance.connect_to_editor(self)
	
	return instance

func _instantiate_command_entry(p_command: StringName, p_data: Dictionary, p_args: Dictionary = {},
								p_margin: float = 4.0) -> FWDebugCommandEditorEntryBase:
	var path: String = _a_ENTRY_PATH % [p_command, p_command]
	var scene: PackedScene = load(path)
	var instance: FWDebugCommandEditorEntryBase = scene.instantiate()
	instance.connect_to_editor(self)
	instance.set_command(p_command)
	instance.set_branches_margin.call_deferred(p_margin)
	instance.set_args.call_deferred(p_args)
	instance.set_data.call_deferred(p_data)
	
	return instance

func _instantiate_command_entry_add(p_command: StringName, p_data: Dictionary, p_args: Dictionary) -> void:
	var instance: FWDebugCommandEditorEntryBase = _instantiate_command_entry(p_command, p_data, p_args)
	var child_count: int = _a_Entries.get_child_count()
	_a_Entries.add_child(instance)
	_a_Entries.move_child(instance, child_count - 1)

func _instantiate_entries(p_entries_data: Array[_EntryInstantiateData], p_data: Array[Dictionary]) -> void:
	for i: int in p_data.size():
		var entry_data: _EntryInstantiateData = p_entries_data[i]
		var data: Dictionary = p_data[i]
		var command: StringName = data[&"Command"]
		var command_data: Dictionary = data[&"Data"].duplicate(true)
		var command_args: Dictionary = data[&"Args"].duplicate(true)
		var branches_margin: float = entry_data.get_branches_margin()
		var parent: Node = entry_data.get_parent()
		var parents: Array[FWDebugCommandEditorEntryBase] = entry_data.get_parents()
		var branch_idx: int = entry_data.get_branch_idx()
		var idx: int = entry_data.get_index()
		var instance: FWDebugCommandEditorEntryBase = _instantiate_command_entry(command, command_data, command_args, branches_margin)
		instance.set_parents(parents)
		instance.set_branch_idx(branch_idx)
		
		parent.add_child(instance)
		parent.move_child(instance, idx)

func _delete_entries(p_entries_data: Array[_EntryInstantiateData]) -> void:
	if p_entries_data.is_empty():
		return
	
	var instances: Array[FWDebugCommandEditorEntryBase] = []
	var size_: int = p_entries_data.size()
	instances.resize(size_)
	for i: int in size_:
		var entry_data: _EntryInstantiateData = p_entries_data[i]
		var instance: FWDebugCommandEditorEntryBase = entry_data.get_instance()
		instances[i] = instance
	
	var first: FWDebugCommandEditorEntryBase = instances[0]
	var last: FWDebugCommandEditorEntryBase = instances[-1]
	var first_idx: int = first.get_index()
	var last_idx: int = last.get_index()
	var next_idx: int = max(first_idx, last_idx) + 1
	
	for instance: FWDebugCommandEditorEntryBase in instances:
		instance.queue_free()
	
	var parent: Container = _get_nearest_parent(first)
	var branch_idx: int = first.get_branch_idx()
	var entry_count: int = parent.get_entries_count(branch_idx)
	var next_focus: FWDebugCommandEditorEntryBase
	if entry_count > next_idx:
		next_focus = parent.get_branch_entry(branch_idx, next_idx)
	else:
		var child_count: int = parent.get_entries_count(branch_idx)
		next_focus = parent.get_branch_entry(branch_idx, child_count - 1)
	next_focus.grab_main_base_focus()
	
	_a_selected = [next_focus]
	_a_first = next_focus

func _add_for_loop_idx_ords(p_res_data: Dictionary) -> void:
	var idx_ords: Array[int] = _get_for_loop_idx_ords(_a_first)
	p_res_data[&"Misc"][&"For_Loop_Idx_Ords"] = idx_ords

func _add_sub_process_id_ords(p_res_data: Dictionary) -> void:
	var id_ords: Array[int] = _get_sub_process_id_ords(_a_first)
	p_res_data[&"Misc"][&"Sub_Process_ID_Ords"] = id_ords

func _option_undo() -> void:
	_a_undo_redo.undo()

func _option_redo() -> void:
	_a_undo_redo.redo()

func _option_new() -> void:
	_a_new_option = true
	var commands_list: FWDebugCommandsList = Debug.get_commands_list()
	commands_list.open()

func _option_edit() -> void:
	if _a_first.is_empty():
		return
	
	var command: StringName = _a_first.get_command()
	var res_data: Dictionary = _get_combined_entry_res_data(_a_first)
	match command:
		&"Loop": _add_for_loop_idx_ords(res_data)
		&"Sub_Process": _add_sub_process_id_ords(res_data)
	
	var dim: StringName = Scene_Manager.get_curr_scene_dim()
	var uid: String = _e_edit_scene_uids[command][dim]
	var data: Dictionary = _a_first.get_data()
	var command_edit: FWDebugCommandEdit = Debug.get_command_edit()
	command_edit.open(_a_first, command, uid, data, res_data)

func _option_cut() -> void:
	var to_copy: Array[FWDebugCommandEditorEntryBase] = _get_selected_entries()
	if to_copy.is_empty():
		return
	
	var entries_data: Array[_EntryInstantiateData] = _get_entries_data(to_copy)
	var clipboard: Array[Dictionary] = _get_clipboard_entries(to_copy)
	Debug.set_command_editor_clipboard(clipboard)
	
	var do_method: Callable = _delete_entries.bind(entries_data)
	var undo_method: Callable = _instantiate_entries.bind(entries_data, clipboard)
	_create_undo_redo_action("Cut", do_method, undo_method)
	_a_Options.set_option_disabled(&"Paste", false)

func _option_copy() -> void:
	var to_copy: Array[FWDebugCommandEditorEntryBase] = _get_selected_entries()
	if to_copy.is_empty():
		return
	
	var clipboard: Array[Dictionary] = _get_clipboard_entries(to_copy)
	Debug.set_command_editor_clipboard(clipboard)
	_a_Options.set_option_disabled(&"Paste", false)

func _option_paste() -> void:
	var clipboard: Array[Dictionary] = Debug.get_command_editor_clipboard()
	if clipboard.is_empty():
		return
	
	var entries_data: Array[_EntryInstantiateData] = []
	var parent: Node = _a_first.get_parent()
	var idx: int = _a_first.get_index()
	var branch_idx: int = _a_first.get_branch_idx()
	var branches_margin: float = _a_first.get_branches_margin()
	var parents: Array[FWDebugCommandEditorEntryBase] = _a_first.get_parents()
	entries_data.resize(clipboard.size())
	for i: int in clipboard.size():
		var entry_data: _EntryInstantiateData = _EntryInstantiateData.new(_a_Entries, parent, idx + i, branch_idx, branches_margin, parents)
		entries_data[i] = entry_data
	
	var do_method: Callable = _instantiate_entries.bind(entries_data, clipboard)
	var undo_method: Callable = _delete_entries.bind(entries_data)
	_create_undo_redo_action("Paste", do_method, undo_method)

func _option_delete() -> void:
	var selected: Array[FWDebugCommandEditorEntryBase] = _get_selected_entries()
	if selected.is_empty():
		return
	
	var entries_data: Array[_EntryInstantiateData] = _get_entries_data(selected)
	var clipboard: Array[Dictionary] = _get_clipboard_entries(selected)
	var do_method: Callable = _delete_entries.bind(entries_data)
	var undo_method: Callable = _instantiate_entries.bind(entries_data, clipboard)
	_create_undo_redo_action("Delete", do_method, undo_method)

func _option_select_all() -> void:
	_a_first = null
	
	var size_: int = _a_Entries.get_entries_count(0) - 1
	_a_selected.resize(size_)
	for i: int in size_:
		var child: FWDebugCommandEditorEntryBase = _a_Entries.get_branch_entry(0, i)
		if i == 0:
			child.grab_main_base_focus()
			_a_first = child
		
		child.set_fake_focus(true)
		_a_selected[i] = child

func _option_test() -> void:
	option_test_selected.emit(_a_first)

func _option_swap_process() -> void:
	var branches_idxs: Array[int] = _a_first.get_used_branches_idxs()
	if branches_idxs.size() > 1:
		_a_first.swap_process_next()

func _option_change_mark(p_mark: StringName) -> void:
	var ref_data: _EntryRefData = _get_entry_ref_data(_a_first)
	var mark: StringName = _a_first.get_mark()
	var do_method: Callable = _set_entry_mark.bind(ref_data, p_mark)
	var undo_method: Callable = _set_entry_mark.bind(ref_data, mark)
	_a_undo_redo.create_action("Change_Mark")
	_a_undo_redo.add_do_method(do_method)
	_a_undo_redo.add_undo_method(undo_method)
	
	if p_mark == &"Test" && is_instance_valid(_a_test_entry):
		ref_data = _get_entry_ref_data(_a_test_entry)
		do_method = _set_entry_mark.bind(ref_data, &"Default")
		undo_method = _set_entry_mark.bind(ref_data, &"Test")
		_a_undo_redo.add_do_method(do_method)
		_a_undo_redo.add_undo_method(undo_method)
	
	_a_undo_redo.commit_action()

func _create_undo_redo_action(p_name: String, p_do_method: Callable, p_undo_method: Callable) -> void:
	_a_undo_redo.create_action(p_name)
	_a_undo_redo.add_do_method(p_do_method)
	_a_undo_redo.add_undo_method(p_undo_method)
	_a_undo_redo.commit_action()

func _shift_logic(p_clicked: FWDebugCommandEditorEntryBase) -> void:
	if _a_selected.is_empty():
		_a_selected = [p_clicked]
		_a_first = p_clicked
		_a_last_focused = p_clicked
		return
	
	# Release focus and clear selected entries
	clear_selected()
	
	var focused_parents: Array[FWDebugCommandEditorEntryBase] = _a_first.get_parents()
	var clicked_parents: Array[FWDebugCommandEditorEntryBase] = p_clicked.get_parents()
	var sel_entry: FWDebugCommandEditorEntryBase
	var nosel_entry: FWDebugCommandEditorEntryBase
	
	# Get nearest parent (We focus the children of that)
	# Get Sel Entry (The Entry which selectes the nearest parent)
	# Get NoSel Entry (The Entry which didnt't select the nearest parent)
	var nearest_parent: Container
	if focused_parents.size() < clicked_parents.size():
		nearest_parent = _get_nearest_parent(_a_first)
		sel_entry = _a_first
		nosel_entry = p_clicked
	else:
		nearest_parent = _get_nearest_parent(p_clicked)
		sel_entry = p_clicked
		nosel_entry = _a_first
	
	# Get instance which is a parent of lo_entry and a child of nearest parent
	var sel_idx: int = sel_entry.get_index()
	var nosel_idx: int = 0
	var children: Array = nearest_parent.get_entries()
	for child: FWDebugCommandEditorEntryBase in children:
		if child.is_ancestor_of(nosel_entry) || child == nosel_entry:
			nosel_idx = child.get_index()
			break
	
	# Set start and end idx
	var start_idx: int = min(sel_idx, nosel_idx)
	var end_idx: int = max(sel_idx, nosel_idx)
	
	var focused_idx: int = nosel_idx
	var clicked_idx: int = sel_idx
	if _a_first == sel_entry:
		focused_idx = sel_idx
		clicked_idx = nosel_idx
	
	# Shift start idx in special cases
	var sel_parents: Array[FWDebugCommandEditorEntryBase] = sel_entry.get_parents()
	var nosel_parents: Array[FWDebugCommandEditorEntryBase] = nosel_entry.get_parents()
	if sel_parents.size() > 0 || nosel_parents.size() > 0:
		if focused_parents.size() < clicked_parents.size():
			if clicked_idx < focused_idx:
				start_idx += 1
		
		if focused_parents.size() > clicked_parents.size():
			if clicked_idx > focused_idx:
				start_idx += 1
	
	# If instances are not in same branch only clicked should be selected
	if !is_entries_in_same_branch(_a_first, p_clicked):
		_a_selected = [p_clicked]
		_a_first = p_clicked
		_a_last_focused = p_clicked
		return
	
	var branch_idx: int = sel_entry.get_branch_idx()
	
	# Focus the entries
	for i: int in range(start_idx, end_idx + 1):
		var instance: FWDebugCommandEditorEntryBase = nearest_parent.get_branch_entry(branch_idx, i)
		instance.set_fake_focus(true)
		_a_selected.push_back(instance)
	
	if !_a_selected.has(_a_first):
		if !focused_parents.is_empty():
			var next_parent: FWDebugCommandEditorEntryBase = focused_parents[-1]
			if _a_selected.has(next_parent):
				_a_first.set_fake_focus(true)
				_a_selected.push_back(_a_first)
	
	_a_last_focused = p_clicked

func _shift_arrows(p_shift: int) -> void:
	var next_focus: FWDebugCommandEditorEntryBase = _a_last_focused
	var parents: Array[FWDebugCommandEditorEntryBase] = _a_last_focused.get_parents()
	var last_focused_idx: int = _a_last_focused.get_index()
	var shifted_idx: int = last_focused_idx + p_shift
	var entry_parent: Container = _a_Entries
	var branch_idxs: Array[int] = _a_last_focused.get_branch_idxs()
	var branch_idx: int
	for i: int in parents.size():
		var idx: int = parents.size() - i - 1
		branch_idx = branch_idxs[branch_idxs.size() - i - 1]
		
		var parent: FWDebugCommandEditorEntryBase = parents[idx]
		var entry_count: int = parent.get_entries_count(branch_idx)
		if shifted_idx >= 0:
			if entry_count > shifted_idx:
				entry_parent = parent
				break
		
		shifted_idx = parent.get_index()
		if p_shift != -1:
			shifted_idx += p_shift
	
	var entries_count: int = entry_parent.get_entries_count(branch_idx)
	if shifted_idx >= 0 && shifted_idx < entries_count:
		next_focus = entry_parent.get_branch_entry(branch_idx, shifted_idx)
	
	_shift_logic(next_focus)
	next_focus.grab_main_base_focus()

func is_entries_in_same_branch(p_focused: FWDebugCommandEditorEntryBase, p_clicked: FWDebugCommandEditorEntryBase) -> bool:
	var bigger_idxs: Array[int]
	var other_idxs: Array[int]
	var focused_idxs: Array[int] = p_focused.get_branch_idxs()
	var clicked_idxs: Array[int] = p_clicked.get_branch_idxs()
	if focused_idxs.size() > clicked_idxs.size():
		bigger_idxs = focused_idxs
		other_idxs = clicked_idxs
	else:
		bigger_idxs = clicked_idxs
		other_idxs = focused_idxs
	
	for i: int in other_idxs.size():
		var other_idx: int = other_idxs[i]
		var biggest_idx: int = bigger_idxs[i]
		if biggest_idx != other_idx:
			return false
	
	return true

func _get_combined_entry_res_data(p_instance: FWDebugCommandEditorEntryBase) -> Dictionary:
	# 1) If p_instance == nested entry, p_instance should be the root parent
	#    end_idx should be one higher and if child == root parent
	#    should deliver res_data till the original p_instance is reached
	# -> root parent collects res_data of all its children (depending on which branch
	#    is chosen (depending on p_instance _a_branch_idx/ root parent _a_process_branch_idx))
	
	var root: FWDebugCommandEditorEntryBase = p_instance
	var org_idx: int = p_instance.get_index()
	var end_idx: int = org_idx
	var parents: Array[FWDebugCommandEditorEntryBase] = p_instance.get_parents()
	if parents.size() > 0:
		# Nested entry
		root = parents[0]
		end_idx = root.get_index() + 1
	
	var res_data: Dictionary = _get_empty_res_data()
	for i: int in end_idx:
		var child: FWDebugCommandEditorEntryBase = _a_Entries.get_child(i)
		if child == root:
			var branch_idx: int = p_instance.get_branch_idx()
			var args: Array[int] = [branch_idx, org_idx]
			child.add_res_data(res_data, args)
		else:
			child.add_res_data(res_data)
	
	return res_data

func _get_empty_res_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Misc"] = {}
	data[&"Misc"][&"For_Loop_Idx_Ords"] = []
	data[&"Misc"][&"Sub_Process_ID_Ords"] = []
	data[&"Objects"] = {}
	data[&"Default_Object"] = &""
	data[&"$Free_Camera"] = {}
	data[&"$Free_Camera"][&"Object"] = &""
	
	return data

func _get_selected_entries() -> Array[FWDebugCommandEditorEntryBase]:
	var selected: Array[FWDebugCommandEditorEntryBase] = []
	for instance: FWDebugCommandEditorEntryBase in _a_selected:
		if instance.is_empty():
			continue
		
		var parents: Array[FWDebugCommandEditorEntryBase] = instance.get_parents()
		var has_parent: bool = false
		for parent: FWDebugCommandEditorEntryBase in parents:
			if _a_selected.has(parent):
				has_parent = true
				break
		if has_parent:
			continue
		
		selected.push_back(instance)
	
	return selected

func _get_nearest_parent(p_entry: FWDebugCommandEditorEntryBase) -> Container:
	var nearest: Container = _a_Entries
	var parents: Array[FWDebugCommandEditorEntryBase] = p_entry.get_parents()
	if !parents.is_empty():
		nearest = parents[-1]
	
	return nearest

func _get_entries_data(p_instances: Array[FWDebugCommandEditorEntryBase]) -> Array[_EntryInstantiateData]:
	var entries_data: Array[_EntryInstantiateData] = []
	var size_: int = p_instances.size()
	entries_data.resize(size_)
	for i: int in size_:
		var instance: FWDebugCommandEditorEntryBase = p_instances[i]
		var parent: Node = instance.get_parent()
		var idx: int = instance.get_index()
		var branch_idx: int = instance.get_branch_idx()
		var branches_margin: float = instance.get_branches_margin()
		var parents: Array[FWDebugCommandEditorEntryBase] = instance.get_parents()
		var entry_data: _EntryInstantiateData = _EntryInstantiateData.new(_a_Entries, parent, idx, branch_idx, branches_margin, parents)
		entries_data[i] = entry_data
	
	return entries_data

func _get_entry_ref_data(p_instance: FWDebugCommandEditorEntryBase) -> _EntryRefData:
	var parent: Node = p_instance.get_parent()
	var idx: int = p_instance.get_index()
	return _EntryRefData.new(_a_Entries, parent, idx)

func _get_clipboard_entries(p_instances: Array[FWDebugCommandEditorEntryBase]) -> Array[Dictionary]:
	var clipboard: Array[Dictionary] = []
	var size_: int = p_instances.size()
	clipboard.resize(size_)
	for i: int in size_:
		var instance: FWDebugCommandEditorEntryBase = p_instances[i]
		var data: Dictionary = instance.get_save_data()
		clipboard[i] = data
	
	return clipboard

func _get_for_loop_idx_ords(p_instance: FWDebugCommandEditorEntryBase) -> Array[int]:
	var idx_ords: Array[int] = []
	var parents: Array[FWDebugCommandEditorEntryBase] = p_instance.get_parents()
	for parent: FWDebugCommandEditorEntryBase in parents:
		var command: StringName = parent.get_command()
		if command == &"Loop":
			var data: Dictionary = parent.get_data()
			var key: StringName = data[&"Key"]
			if key == &"For":
				var idx_ord: int = int(data[&"Args"][&"Idx_Ord"])
				idx_ords.push_back(idx_ord)
	
	return idx_ords

func _get_sub_process_id_ords(p_instance: FWDebugCommandEditorEntryBase) -> Array[int]:
	var id_ords: Array[int] = []
	var parents: Array[FWDebugCommandEditorEntryBase] = p_instance.get_parents()
	for parent: FWDebugCommandEditorEntryBase in parents:
		var command: StringName = parent.get_command()
		if command == &"Sub_Process":
			var data: Dictionary = parent.get_data()
			var id_ord: int = int(data[&"ID"][&"Value"])
			id_ords.push_back(id_ord)
	
	return id_ords

func get_skip_idxs(p_instance: FWDebugCommandEditorEntryBase = null) -> Array[int]:
	if p_instance == null:
		if _a_test_entry == null:
			p_instance = _a_Entries.get_child(0)
		else:
			p_instance = _a_test_entry
	
	var parents: Array[FWDebugCommandEditorEntryBase] = p_instance.get_parents()
	var size_: int = parents.size()
	var idxs: Array[int] = []
	idxs.resize(size_ + 1)
	for i: int in size_:
		var parent: FWDebugCommandEditorEntryBase = parents[i]
		var parent_idx: int = parent.get_index()
		idxs[i] = parent_idx
	idxs[size_] = p_instance.get_index()
	
	return idxs

func set_active(p_active: bool) -> void:
	if _a_active == p_active:
		return
	
	var commands_list: FWDebugCommandsList = Debug.get_commands_list()
	var command_edit: FWDebugCommandEdit = Debug.get_command_edit()
	if p_active:
		commands_list.command_selected.connect(_on_Commands_List_command_selected)
		commands_list.closed.connect(_on_Commands_List_closed)
		command_edit.command_ok.connect(_on_Command_Edit_command_ok)
	else:
		commands_list.command_selected.disconnect(_on_Commands_List_command_selected)
		commands_list.closed.disconnect(_on_Commands_List_closed)
		command_edit.command_ok.disconnect(_on_Command_Edit_command_ok)
	
	set_process_unhandled_input(p_active)
	_a_active = p_active

func get_cutscene_data() -> Array[Dictionary]:
	var cutscene_data: Array[Dictionary] = []
	for child: FWDebugCommandEditorEntryBase in _a_Entries.get_children():
		if !child.is_empty():
			var data: Array[Dictionary] = child.get_cutscene_data()
			cutscene_data.append_array(data)
	
	return cutscene_data

func get_save_data() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for child: FWDebugCommandEditorEntryBase in _a_Entries.get_children():
		if !child.is_empty():
			var entry_data: Dictionary = child.get_save_data()
			data.push_back(entry_data)
	
	return data

func _on_Commands_List_command_selected(p_command: StringName) -> void:
	var res_data: Dictionary = _get_combined_entry_res_data(_a_first)
	match p_command:
		&"Loop": _add_for_loop_idx_ords(res_data)
		&"Sub_Process": _add_sub_process_id_ords(res_data)
	
	var dim: StringName = Scene_Manager.get_curr_scene_dim()
	var uid: String = _e_edit_scene_uids[p_command][dim]
	var command_edit: FWDebugCommandEdit = Debug.get_command_edit()
	if _a_new_option:
		command_edit.open(_a_first, p_command, uid, {}, res_data)
	else:
		var data: Dictionary = _a_first.get_data()
		command_edit.open(_a_first, p_command, uid, data, res_data)

func _on_Commands_List_closed() -> void:
	_a_new_option = false

func _on_Command_Edit_command_ok(p_data: Dictionary, p_command: StringName) -> void:
	if _a_new_option:
		var entries_data: Array[_EntryInstantiateData] = _get_entries_data([_a_first])
		var data: Dictionary = {}
		data[&"Command"] = p_command
		data[&"Data"] = p_data
		data[&"Args"] = {}
		var data_: Array[Dictionary] = [data]
		var do_method: Callable = _instantiate_entries.bind(entries_data, data_)
		var undo_method: Callable = _delete_entries.bind(entries_data)
		_create_undo_redo_action("New", do_method, undo_method)
	else:
		var curr_data: Dictionary = _a_first.get_data()
		if p_data != curr_data:
			var parent: Node = _a_first.get_parent()
			var idx: int = _a_first.get_index()
			var ref_data: _EntryRefData = _EntryRefData.new(_a_Entries, parent, idx)
			var do_method: Callable = _set_entry_data.bind(ref_data, p_data)
			var undo_method: Callable = _set_entry_data.bind(ref_data, curr_data)
			_create_undo_redo_action("Edit", do_method, undo_method)
	
	var commands_list: FWDebugCommandsList = Debug.get_commands_list()
	_a_first.grab_main_base_focus()
	commands_list.close()

func _set_entry_data(p_ref_data: _EntryRefData, p_data: Dictionary) -> void:
	var instance: FWDebugCommandEditorEntryBase = p_ref_data.get_instance()
	instance.set_data(p_data)

func _set_entry_mark(p_ref_data: _EntryRefData, p_mark: StringName) -> void:
	var instance: FWDebugCommandEditorEntryBase = p_ref_data.get_instance()
	instance.set_mark(p_mark)
	
	match p_mark:
		&"Test":
			_a_test_entry = instance
		_:
			if _a_test_entry == instance:
				_a_test_entry = null

func _on_Options_option_selected(p_option: StringName) -> void:
	match p_option:
		&"Undo": _option_undo()
		&"Redo": _option_redo()
		&"New": _option_new()
		&"Edit": _option_edit()
		&"Cut": _option_cut()
		&"Copy": _option_copy()
		&"Paste": _option_paste()
		&"Delete": _option_delete()
		&"Select_All": _option_select_all()
		&"Test": _option_test()
		&"Swap_Process": _option_swap_process()
		&"Change_Mark_Default": _option_change_mark(&"Default")
		&"Change_Mark_Test": _option_change_mark(&"Test")

func _on_Undo_Redo_version_changed() -> void:
	var has_undo: bool = _a_undo_redo.has_undo()
	var has_redo: bool = _a_undo_redo.has_redo()
	_a_Options.set_option_disabled(&"Undo", !has_undo)
	_a_Options.set_option_disabled(&"Redo", !has_redo)

func _on_Debug_closing() -> void:
	_a_Options.close()

func _on_Entry_activated() -> void:
	_option_new()

func _on_Entry_selectable_focus_entered(p_instance: FWDebugCommandEditorEntryBase) -> void:
	if !Input.is_action_pressed(&"Shift"):
		clear_selected()
		p_instance.set_fake_focus(true)
		p_instance.grab_main_base_focus()
		_a_selected = [p_instance]
		_a_first = p_instance
	
	_a_last_focused = p_instance
	selectable_focus_entered.emit()

func _on_Entry_selectable_left_clicked(p_instance: FWDebugCommandEditorEntryBase) -> void:
	if Input.is_action_pressed(&"Shift"):
		_shift_logic(p_instance)

func _on_Entry_selectable_right_clicked(p_pos: Vector2, p_instance: FWDebugCommandEditorEntryBase) -> void:
	if p_instance.is_empty():
		var options: Array[StringName] = [&"Change_Mark", &"Copy", &"Cut", &"Delete", &"Edit", &"Test"]
		_a_Options.set_options_disabled(options, true)
	else:
		var options: Array[StringName] = _a_Options.get_option_names()
		_a_Options.set_options_disabled(options, false, [&"Undo", &"Redo", &"Paste"])
	
	p_instance.set_fake_focus(true)
	if !_a_selected.has(p_instance):
		clear_selected()
		_a_selected = [p_instance]
	_a_first = p_instance
	
	var branches_idxs: Array[int] = p_instance.get_used_branches_idxs()
	var show_swap_process: bool = branches_idxs.size() > 1
	_a_Options.set_option_visible(&"Swap_Process", show_swap_process)
	_a_Options.open(p_pos)

func _on_Entry_arg_focus_entered(p_instance: FWDebugCommandEditorEntryBase) -> void:
	if Input.is_action_pressed(&"Shift"):
		_shift_logic(p_instance)
	else:
		clear_selected()
		_a_first = p_instance

func _on_Entry_arg_right_clicked(p_pos: Vector2, p_instance: FWDebugCommandEditorEntryBase) -> void:
	if _a_selected.has(p_instance):
		var options: Array[StringName] = _a_Options.get_option_names()
		_a_Options.set_options_disabled(options, false, [&"Undo", &"Redo", &"Paste"])
		p_instance.set_fake_focus(true)
	else:
		clear_selected()
		var options: Array[StringName] = _a_Options.get_option_names()
		_a_Options.set_option_disabled(&"Select_All", false)
		_a_Options.set_options_disabled(options, true, [&"Undo", &"Redo", &"Select_All"])
		_a_first = p_instance
	
	_a_Options.set_option_visible(&"Swap_Process", false)
	_a_Options.open(p_pos)

func _on_Entry_warning_pressed(p_pos: Vector2, p_instance: FWDebugCommandEditorEntryBase) -> void:
	_a_Warnings.open(p_pos, p_instance)

func _on_Entry_unselectable_focus_entered() -> void:
	clear_selected()

func _on_Entry_unselectable_right_clicked(p_pos: Vector2) -> void:
	clear_selected()
	
	var options: Array[StringName] = _a_Options.get_option_names()
	_a_Options.set_option_disabled(&"Select_All", false)
	_a_Options.set_options_disabled(options, true, [&"Undo", &"Redo", &"Select_All"])
	_a_Options.set_option_visible(&"Swap_Process", false)
	_a_Options.open(p_pos)

func _on_Entry_request_empty_entry(p_branch_idx: int, p_margin: float, p_entries: VBoxContainer,
								   p_entry: FWDebugCommandEditorEntryBase) -> void:
	var instance: FWDebugCommandEditorEntryBase = _instantiate_empty_entry()
	var parents: Array[FWDebugCommandEditorEntryBase] = p_entry.get_parents().duplicate()
	parents.push_back(p_entry)
	instance.set_parents(parents)
	instance.set_branch_idx(p_branch_idx)
	instance.set_branches_margin.call_deferred(p_margin)
	p_entries.add_child(instance)

func _on_Entry_request_command_entry(p_command: StringName, p_data: Dictionary, p_branch_idx: int, p_margin: float,
									 p_entries: VBoxContainer, p_entry: FWDebugCommandEditorEntryBase) -> void:
	var instance: FWDebugCommandEditorEntryBase = _instantiate_command_entry(p_command, p_data[&"Data"], p_data[&"Args"], p_margin)
	var parents: Array[FWDebugCommandEditorEntryBase] = p_entry.get_parents().duplicate()
	parents.push_back(p_entry)
	instance.set_parents(parents)
	instance.set_branch_idx(p_branch_idx)
	p_entries.add_child(instance)

class _EntryInstantiateData extends _EntryRefData:
	var _a_branch_idx: int
	var _a_branches_margin: float
	var _a_parents_paths: Array[NodePath] = []
	
	func _init(p_origin: Node, p_parent: Node, p_idx: int, p_branch_idx: int,
			   p_branches_margin: float, p_parents: Array[FWDebugCommandEditorEntryBase]) -> void:
		super(p_origin, p_parent, p_idx)
		_a_branch_idx = p_branch_idx
		_a_branches_margin = p_branches_margin
		
		var size_: int = p_parents.size()
		_a_parents_paths.resize(size_)
		for i: int in size_:
			var parent: FWDebugCommandEditorEntryBase = p_parents[i]
			var parent_path: NodePath = p_origin.get_path_to(parent)
			_a_parents_paths[i] = parent_path
	
	func get_branches_margin() -> float:
		return _a_branches_margin
	
	func get_branch_idx() -> int:
		return _a_branch_idx
	
	func get_index() -> int:
		return _a_idx
	
	func get_parent() -> FWDebugCommandEditorEntryBase:
		return _a_origin.get_node(_a_parent_path)
	
	func get_parents() -> Array[FWDebugCommandEditorEntryBase]:
		var parents: Array[FWDebugCommandEditorEntryBase] = []
		var size_: int = _a_parents_paths.size()
		parents.resize(size_)
		for i: int in size_:
			var parent_path: NodePath = _a_parents_paths[i]
			var parent: FWDebugCommandEditorEntryBase = _a_origin.get_node(parent_path)
			parents[i] = parent
		
		return parents

class _EntryRefData:
	var _a_origin: Node
	var _a_parent_path: NodePath
	var _a_idx: int
	
	func _init(p_origin: Node, p_parent: Node, p_idx: int) -> void:
		_a_origin = p_origin
		_a_parent_path = p_origin.get_path_to(p_parent)
		_a_idx = p_idx
	
	func get_instance() -> FWDebugCommandEditorEntryBase:
		var parent: Node = _a_origin.get_node(_a_parent_path)
		var instance: FWDebugCommandEditorEntryBase = parent.get_child(_a_idx)
		
		return instance
