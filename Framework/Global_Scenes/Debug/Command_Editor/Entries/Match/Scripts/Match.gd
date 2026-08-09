extends FWDebugCommandEditorEntryBranch
class_name FWDebugCommandEditorEntryMatch

var _a_Branch_Base_Scene: PackedScene = preload("uid://c8lns07r4xyu8")

func swap_process_next() -> void:
	var child_count: int = _a_Branches.get_child_count()
	var next_branch_idx: int = max(1, (_a_process_branch_idx + 1) % child_count)
	swap_process(next_branch_idx)

# Breakable: Choices: [&"Menus"][&"Choices"][&"Chapter"][&"Value"] NOT IMPLEMENTED!!!
#					  [&"Menus"][&"Choices"][&"Location"][&"Value"] NOT IMPLEMENTED!!!
#					  [&"Menus"][&"Choices"][&"Dialogue"][&"Value"]
#					  [&"Menus"][&"Choices"][&"Part"][&"Value"]
#			 Script: [&"Menus"][&"Script"][&"Expression"][&"Instance_Key"]
func _update_warnings_add() -> void:
	var key: StringName = _a_data[&"Key"]
	var menu_data: Dictionary = _a_data[&"Menus"][key]
	match key:
		&"Choices":
			var key_type: StringName = menu_data[&"Key_Type"][&"Value"]
			var chapter: StringName = menu_data[&"Chapter"][&"Value"]
			var location: StringName = menu_data[&"Location"][&"Value"]
			var dialogue_key: StringName = menu_data[&"Dialogue"][&"Value"]
			var dialogues_data: Dictionary = Databases.get_global_map_data(&"Dialogues", key_type, chapter, location)
			if dialogues_data.has(dialogue_key):
				var part_entry_key: StringName = menu_data[&"Part"][&"Value"]
				var parts_data: Dictionary = dialogues_data[dialogue_key][&"Data"]
				if !parts_data.has(part_entry_key):
					var value_keys: Array = [&"Menus", &"Choices", &"Part", &"Value"]
					var args: WarningArgsStringName = WarningArgsStringName.new(part_entry_key, value_keys)
					_a_warnings.push_back(args)
			else:
				var value_keys: Array = [&"Menus", &"Choices", &"Dialogue", &"Value"]
				var args: WarningArgsStringName = WarningArgsStringName.new(dialogue_key, value_keys)
				_a_warnings.push_back(args)
		
		&"Script":
			var value_keys: Array = [&"Menus", &"Script", &"Expression", &"Instance_Key"]
			var expression_args: Dictionary = menu_data[&"Expression"]
			_update_warnings_add_expression(expression_args, value_keys)

func _update_display_main_base_args() -> void:
	var key: StringName = _a_data[&"Key"]
	var menu_data: Dictionary = _a_data[&"Menus"][key]
	
	var text: String = ""
	match key:
		&"Choices":
			var dialogue_key: String = _get_display_text(menu_data[&"Dialogue"])
			var part_entry_key: String = _get_display_text(menu_data[&"Part"])
			text = "%s: " % tr(&"FW_CHOICES")
			text += dialogue_key
			text += ", %s: " % tr(&"FW_DEBUG_PART")
			text += part_entry_key
		
		&"Script":
			var instance_key: String = menu_data[&"Expression"][&"Instance_Key"]
			var expression: String = menu_data[&"Expression"][&"Expression"]
			text = "%s: " % tr(&"FW_DEBUG_CUTSCENES_SCRIPT")
			text += instance_key
			text += ": %s" % expression
	_a_Main.set_base_args(text)

func _delete_branches(p_from: int) -> void:
	for i: int in range(p_from, _a_Branches.get_child_count()):
		var child: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i)
		child.queue_free()

func _instantiate_branches(p_values, p_from: int) -> void:
	var base_min_size: Vector2 = _a_Main.get_base_margin_min_size()
	var margin: float = _get_main_arg_margin()
	for i: int in range(p_from, p_values.size()):
		var branch_name: String = str(p_values[i])
		var margin_min_size: Vector2 = Vector2(margin, base_min_size.y)
		_instantiate_branch(branch_name, margin_min_size)

func _instantiate_branch(p_branch_name: String, p_margin_min_size: Vector2) -> void:
	var instance: FWDebugCommandEditorBranchBase = _a_Branch_Base_Scene.instantiate()
	instance.base_focus_entered.connect(_on_Unselectable_focus_entered)
	instance.base_gui_input.connect(_on_Unselectable_gui_input)
	instance.progress_focus_entered.connect(_on_Unselectable_focus_entered)
	instance.progress_gui_input.connect(_on_Unselectable_gui_input)
	instance.set_base_desc.call_deferred(p_branch_name)
	instance.set_base_desc_modulate.call_deferred(_e_color)
	instance.set_base_margin_min_size.call_deferred(p_margin_min_size)
	
	_a_Branches.add_child(instance)

func _init_branches() -> void:
	var key: StringName = _a_data[&"Key"]
	var branches_values = _a_data[&"Menus"][key][&"Branches_Values"]
	_instantiate_branches(branches_values, 0)
	
	# Frame needed for branches to be ready
	await get_tree().process_frame
	super()

func _update_branches() -> void:
	var key: StringName = _a_data[&"Key"]
	var branches_values: Array = _a_data[&"Menus"][key][&"Branches_Values"]
	var child_count: int = _a_Branches.get_child_count()
	var branches_count: int = branches_values.size()
	var to: int = child_count - 1
	if to > branches_count:
		var from: int = branches_count + 1
		_delete_branches(from)
		to = branches_count
	
	for i: int in to:
		var branch_name: String = str(branches_values[i])
		var child: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i + 1)
		child.set_base_desc(branch_name)
	_instantiate_branches(branches_values, to)
	
	# Frame needed for old branches to be freed and new branches to be ready
	await get_tree().process_frame
	
	var margin: float = _get_main_arg_margin()
	for i: int in range(to + 1, branches_count + 1):
		var child: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i)
		var entries: VBoxContainer = child.get_entries_instance()
		request_empty_entry.emit(i, margin, entries)
	
	_a_process_branch_idx = min(_a_process_branch_idx, branches_count)
	swap_process(_a_process_branch_idx)
	
	for i: int in range(1, _a_Branches.get_child_count()):
		var child: FWDebugCommandEditorBranchBase = _a_Branches.get_child(i)
		var process_margin: Control = child.get_process_margin_instance()
		process_margin.custom_minimum_size.x = margin
		child.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func set_args(p_args: Dictionary) -> void:
	super(p_args)
	if !_a_args.has(&"Process_Branch_Idx"):
		_a_args[&"Process_Branch_Idx"] = 1
