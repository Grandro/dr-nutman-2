extends HBoxContainer
class_name FWDebugCommandEditor

signal option_test_selected(p_instance: FWDebugCommandEditorEntryBase)
signal selectable_focus_entered()

@export var _e_edit_scene_uids: Dictionary = {} # [Command][Dim] = uid

var _a_Entry_Base_Scene: PackedScene = preload("uid://bc28ss3fdbnss")

const _a_ENTRY_PATH: String = "res://Framework/Global_Scenes/Debug/Command_Editor/Entries/%s/%s.tscn"

@onready var _a_Entries: VBoxContainer = get_node("Contents/Panel/Entries")
@onready var _a_Options: FWDebugCommandEditorOptions = get_node("Contents/Panel/Options")
@onready var _a_Warnings: FWDebugCommandEditorWarnings = get_node("Contents/Panel/Warnings")

var _a_active: bool = false # Is currently active?
var _a_new_option: bool = false # Commands_List openend to create a new entry?
var _a_selected: Array[FWDebugCommandEditorEntryBase] = [] # Selected entries 
var _a_first: FWDebugCommandEditorEntryBase = null # First selected entry
var _a_last_focused: FWDebugCommandEditorEntryBase = null # Last focused entry
var _a_test_entry: FWDebugCommandEditorEntryBase = null # Entry with test mark

func _ready() -> void:
	_a_Options.option_selected.connect(_on_Options_option_selected)
	Debug.closing.connect(_on_Debug_closing)
	
	set_process_unhandled_input(false)

func _unhandled_input(p_event: InputEvent) -> void:
	if _a_Options.is_visible():
		return
	
	if p_event.is_action_pressed(&"Space"):
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
	instance.update_data.call_deferred(p_data)
	
	return instance

func _instantiate_command_entry_add(p_command: StringName, p_data: Dictionary, p_args: Dictionary) -> void:
	var instance: FWDebugCommandEditorEntryBase = _instantiate_command_entry(p_command, p_data, p_args)
	var child_count: int = _a_Entries.get_child_count()
	_a_Entries.add_child(instance)
	_a_Entries.move_child(instance, child_count - 1)

func _add_for_loop_idx_ords(p_res_data: Dictionary) -> void:
	var idx_ords: Array[int] = _get_for_loop_idx_ords(_a_first)
	p_res_data[&"Misc"][&"For_Loop_Idx_Ords"] = idx_ords

func _add_sub_process_id_ords(p_res_data: Dictionary) -> void:
	var id_ords: Array[int] = _get_sub_process_id_ords(_a_first)
	p_res_data[&"Misc"][&"Sub_Process_ID_Ords"] = id_ords

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
	var to_copy: Array[FWDebugCommandEditorEntryBase] = _get_selected_copyable()
	if to_copy.is_empty():
		return
	
	var first_idx: int = _a_first.get_index()
	var last: FWDebugCommandEditorEntryBase = to_copy.back()
	var last_idx: int = last.get_index()
	var next_idx: int = max(first_idx, last_idx) + 1
	
	var clipboard: Array[Dictionary] = []
	for instance: FWDebugCommandEditorEntryBase in to_copy:
		var data: Dictionary = instance.get_save_data()
		clipboard.push_back(data)
		instance.queue_free()
	Debug.set_command_editor_clipboard(clipboard)
	
	var parent: Container = _get_nearest_parent(_a_first)
	var branch_idx: int = _a_first.get_branch_idx()
	var entry_count: int
	if parent == _a_Entries:
		entry_count = parent.get_child_count()
	else:
		entry_count = parent.get_entries_count(branch_idx)
	
	if entry_count > next_idx:
		var next_focus: FWDebugCommandEditorEntryBase
		if parent == _a_Entries:
			next_focus = parent.get_child(next_idx)
		else:
			next_focus = parent.get_branch_entry(branch_idx, next_idx)
		next_focus.grab_main_base_focus()
		
		_a_selected = [next_focus]
		_a_first = next_focus
	
	_a_Options.set_option_disabled(&"Paste", false)

func _option_copy() -> void:
	var to_copy: Array[FWDebugCommandEditorEntryBase] = _get_selected_copyable()
	if to_copy.is_empty():
		return
	
	var clipboard: Array[Dictionary] = []
	for instance in to_copy:
		var data: Dictionary = instance.get_save_data()
		clipboard.push_back(data)
	Debug.set_command_editor_clipboard(clipboard)
	
	_a_Options.set_option_disabled(&"Paste", false)

func _option_paste() -> void:
	var clipboard: Array[Dictionary] = Debug.get_command_editor_clipboard()
	if clipboard.is_empty():
		return
	
	var parents: Array[FWDebugCommandEditorEntryBase] = _a_first.get_parents().duplicate()
	var branch_idx: int = _a_first.get_branch_idx()
	var margin: float = _a_first.get_branches_margin()
	var parent: Node = _a_first.get_parent()
	var focused_idx: int = _a_first.get_index()
	var size_: int = clipboard.size()
	for i: int in size_:
		var idx: int = size_ - 1 - i
		var data: Dictionary = clipboard[idx]
		var command: StringName = data[&"Command"]
		var command_data: Dictionary = data[&"Data"]
		var command_args: Dictionary = data[&"Args"]
		
		var instance: FWDebugCommandEditorEntryBase = _instantiate_command_entry(command, command_data, command_args, margin)
		instance.set_parents(parents)
		instance.set_branch_idx(branch_idx)
		
		parent.add_child(instance)
		parent.move_child(instance, focused_idx)

func _option_delete() -> void:
	var selected: Array[FWDebugCommandEditorEntryBase] = _get_selected_copyable()
	if selected.is_empty():
		return
	
	var first_idx: int = _a_first.get_index()
	var last: FWDebugCommandEditorEntryBase = selected.back()
	var last_idx: int = last.get_index()
	var next_idx: int = max(first_idx, last_idx) + 1
	
	for instance: FWDebugCommandEditorEntryBase in selected:
		instance.queue_free()
	
	var parent: Container = _get_nearest_parent(_a_first)
	var branch_idx: int = _a_first.get_branch_idx()
	var entry_count: int
	if parent == _a_Entries:
		entry_count = parent.get_child_count()
	else:
		entry_count = parent.get_entries_count(branch_idx)
	
	var next_focus: FWDebugCommandEditorEntryBase
	if entry_count > next_idx:
		if parent == _a_Entries:
			next_focus = parent.get_child(next_idx)
		else:
			next_focus = parent.get_branch_entry(branch_idx, next_idx)
	else:
		if parent == _a_Entries:
			var child_count: int = parent.get_child_count()
			next_focus = parent.get_child(child_count - 1)
		else:
			var child_count: int = parent.get_entries_count(branch_idx)
			next_focus = parent.get_branch_entry(branch_idx, child_count - 1)
	
	next_focus.grab_main_base_focus()
	
	_a_selected = [next_focus]
	_a_first = next_focus

func _option_select_all() -> void:
	_a_selected.clear()
	_a_first = null
	
	var children: Array[Node] = _a_Entries.get_children()
	for i: int in children.size() - 1:
		var child: FWDebugCommandEditorEntryBase = children[i]
		if i == 0:
			child.grab_main_base_focus()
			_a_first = child
		
		child.set_fake_focus(true)
		_a_selected.push_back(child)

func _option_test() -> void:
	option_test_selected.emit(_a_first)

func _option_swap_process() -> void:
	var branches_idxs: Array[int] = _a_first.get_used_branches_idxs()
	if branches_idxs.size() <= 1:
		return
	
	_a_first.swap_process_next()

func _option_change_mark(p_mark: StringName) -> void:
	_a_first.set_mark(p_mark)

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
	
	var children: Array
	if nearest_parent == _a_Entries:
		children = nearest_parent.get_children()
	else:
		children = nearest_parent.get_entries()
	
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
		var entry: FWDebugCommandEditorEntryBase
		if nearest_parent == _a_Entries:
			entry = nearest_parent.get_child(i)
		else:
			entry = nearest_parent.get_branch_entry(branch_idx, i)
		
		entry.set_fake_focus(true)
		_a_selected.push_back(entry)
	
	if !_a_selected.has(_a_first):
		if focused_parents.size() > 0:
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
		
		var parent_idx: int = parent.get_index()
		if p_shift == -1:
			shifted_idx = parent_idx
		else:
			shifted_idx = parent_idx + p_shift
	
	if entry_parent == _a_Entries:
		if shifted_idx >= 0:
			if _a_Entries.get_child_count() > shifted_idx:
				next_focus = _a_Entries.get_child(shifted_idx)
	else:
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

func _get_selected_real() -> Array[FWDebugCommandEditorEntryBase]:
	# First entry in a_selected could be nested too deep
	var entries: Array[FWDebugCommandEditorEntryBase] = []
	for entry: FWDebugCommandEditorEntryBase in _a_selected:
		if entry == _a_first:
			if _a_selected.size() > 1:
				var second: FWDebugCommandEditorEntryBase = _a_selected[1]
				var first_parents: Array[FWDebugCommandEditorEntryBase] = _a_first.get_parents()
				var second_parents: Array[FWDebugCommandEditorEntryBase] = second.get_parents()
				if first_parents.size() > second_parents.size():
					continue
		
		entries.push_back(entry)
	
	return entries

func _get_selected_copyable() -> Array[FWDebugCommandEditorEntryBase]:
	# Command of entry could be empty
	var entries: Array[FWDebugCommandEditorEntryBase] = []
	var real_entries: Array[FWDebugCommandEditorEntryBase] = _get_selected_real()
	for entry: FWDebugCommandEditorEntryBase in real_entries:
		if !entry.is_empty():
			entries.push_back(entry)
	
	return entries

func _get_nearest_parent(p_entry: FWDebugCommandEditorEntryBase) -> Container:
	var nearest: Container = _a_Entries
	var parents: Array[FWDebugCommandEditorEntryBase] = p_entry.get_parents()
	if parents.size() > 0:
		nearest = parents[-1]
	
	return nearest

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
	var idxs: Array[int] = []
	for parent: FWDebugCommandEditorEntryBase in parents:
		var parent_idx: int = parent.get_index()
		idxs.push_back(parent_idx)
	var idx: int = p_instance.get_index()
	idxs.push_back(idx)
	
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
		var margin: float = _a_first.get_branches_margin()
		var parent: Node = _a_first.get_parent()
		var instance: FWDebugCommandEditorEntryBase = _instantiate_command_entry(p_command, p_data, {}, margin)
		var parents: Array[FWDebugCommandEditorEntryBase] = _a_first.get_parents().duplicate()
		var branch_idx: int = _a_first.get_branch_idx()
		instance.set_parents(parents)
		instance.set_branch_idx(branch_idx)
		
		var idx: int = _a_first.get_index()
		parent.add_child(instance)
		parent.move_child(instance, idx)
	else:
		_a_first.update_data(p_data)
	
	_a_first.grab_main_base_focus()
	
	var commands_list: FWDebugCommandsList = Debug.get_commands_list()
	commands_list.close()

func _on_Options_option_selected(p_option: StringName) -> void:
	match p_option:
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

func _on_Debug_closing() -> void:
	_a_Options.close()

func _on_Entry_activated() -> void:
	_option_new()

func _on_Entry_selectable_focus_entered(p_instance: FWDebugCommandEditorEntryBase) -> void:
	if !Input.is_action_pressed(&"Shift"):
		for instance: FWDebugCommandEditorEntryBase in _a_selected:
			if instance != p_instance:
				instance.set_fake_focus(false)
				instance.release_main_base_focus()
		p_instance.set_fake_focus(true)
		
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
		for option: StringName in options:
			_a_Options.set_option_disabled(option, true)
	else:
		_a_Options.set_options_disabled_all(false, [&"Paste"])
	
	p_instance.set_fake_focus(true)
	if !_a_selected.has(p_instance):
		for instance: FWDebugCommandEditorEntryBase in _a_selected:
			instance.set_fake_focus(false)
			instance.release_main_base_focus()
		
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
		for instance: FWDebugCommandEditorEntryBase in _a_selected:
			instance.release_main_base_focus()
			instance.set_fake_focus(false)
		
		_a_selected.clear()
		_a_first = p_instance

func _on_Entry_arg_right_clicked(p_pos: Vector2, p_instance: FWDebugCommandEditorEntryBase) -> void:
	if _a_selected.has(p_instance):
		_a_Options.set_options_disabled_all(false)
		p_instance.set_fake_focus(true)
	else:
		for instance: FWDebugCommandEditorEntryBase in _a_selected:
			instance.release_main_base_focus()
			instance.set_fake_focus(false)
		
		_a_selected.clear()
		_a_first = p_instance
		_a_Options.set_options_disabled([&"Select_All"], false, true)
	
	_a_Options.set_option_visible(&"Swap_Process", false)
	_a_Options.open(p_pos)

func _on_Entry_warning_pressed(p_pos: Vector2, p_instance: FWDebugCommandEditorEntryBase) -> void:
	_a_Warnings.open(p_pos, p_instance)

func _on_Entry_mark_changed(p_mark: StringName, p_instance: FWDebugCommandEditorEntryBase) -> void:
	match p_mark:
		&"Default":
			if _a_test_entry == p_instance:
				_a_test_entry = null
		&"Test":
			if is_instance_valid(_a_test_entry):
				_a_test_entry.set_mark(&"Default")
			_a_test_entry = p_instance

func _on_Entry_unselectable_focus_entered() -> void:
	clear_selected()

func _on_Entry_unselectable_right_clicked(p_pos: Vector2) -> void:
	clear_selected()
	
	_a_Options.set_options_disabled([&"Select_All"], false, true)
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
