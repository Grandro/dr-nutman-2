extends DebugCommandEditorEntryBranch
class_name DebugCommandEditorEntryCondBranch

@onready var _a_Else: DebugCommandEditorBranchBase = get_node("HBox/VBox/Branches/Else")

func _ready() -> void:
	super()
	
	_a_Else.base_focus_entered.connect(_on_Unselectable_focus_entered)
	_a_Else.base_gui_input.connect(_on_Unselectable_gui_input)
	for child: DebugCommandEditorBranchBase in _a_Branches.get_children():
		child.progress_focus_entered.connect(_on_Unselectable_focus_entered)
		child.progress_gui_input.connect(_on_Unselectable_gui_input)
	
	_a_Else.set_base_desc(tr(&"DEBUG_CUTSCENES_ELSE"))
	_a_Else.hide()

func update_display() -> void:
	super()
	_a_Else.set_base_desc_modulate(_e_color)

# Breakable: Items: [&"Menus"][&"Items"][&"Item"][&"Value"],
#					[&"Menus"][&"Items"][&"Amount"][&"Value"][&"Min"][&"Value"] /
#					[&"Menus"][&"Items"][&"Amount"][&"Value"][&"Max"][&"Value"]
#			 Script: [&"Menus"][&"Script"][&"Instance_Key"]
func _update_warnings_add() -> void:
	var menus_data: Dictionary = _a_data[&"Menus"]
	for key: StringName in menus_data:
		match key:
			&"Items": _update_warnings_add_items(menus_data[key])
			&"Script": _update_warnings_add_script(menus_data[key])

func _update_warnings_add_items(p_data: Dictionary) -> void:
	var item_key: StringName = p_data[&"Item"][&"Value"]
	if item_key == &"":
		return
	
	var items_data: Dictionary = Databases.get_data(&"Items")
	if !items_data.has(item_key):
		var value_keys: Array = [&"Menus", &"Items", &"Item", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(item_key, value_keys)
		_a_warnings.push_back(args)
	else:
		var stack: int = items_data[item_key].get_stack_()
		var max_value: int = p_data[&"Amount"][&"Value"][&"Max"][&"Value"]
		if max_value > stack:
			var min_value: int = p_data[&"Amount"][&"Value"][&"Min"][&"Value"]
			var value: String = "%s - %s" % [str(min_value), str(max_value)]
			var value_keys_min: Array = [&"Menus", &"Items", &"Amount", &"Value", &"Min", &"Value"]
			var value_keys_max: Array = [&"Menus", &"Items", &"Amount", &"Value", &"Max", &"Value"]
			var value_keys: Array = [value_keys_min, value_keys_max]
			var args: WarningArgsRange = WarningArgsRange.new(value, value_keys, 0, stack)
			_a_warnings.push_back(args)

func _update_warnings_add_script(p_data: Dictionary) -> void:
	_update_warnings_add_expression(p_data, [&"Menus", &"Script", &"Instance_Key"])

func _update_display_main_base_args() -> void:
	var option_key: StringName = _a_data[&"Key"]
	var text: String = "%s: " % tr("DEBUG_CUTSCENES_%s" % option_key.to_upper())
	var menu_data: Dictionary = _a_data[&"Menus"][option_key]
	match option_key:
		&"Items":
			var key_text: String = _get_display_text(menu_data[&"Item"])
			text += key_text
			
			var amount_type: StringName = menu_data[&"Amount"][&"Type"]
			var amount_args: Dictionary = menu_data[&"Amount"][amount_type]
			match amount_type:
				&"Var":
					var amount_text: String = _get_var_display_text(amount_args)
					text += amount_text
				
				&"Value":
					var amount_min_text: String = _get_display_text(amount_args[&"Min"])
					var amount_max_text: String = _get_display_text(amount_args[&"Max"])
					text += ", %s " % tr(&"DEBUG_CUTSCENES_AMOUNT")
					text += "%s - %s" % [amount_min_text, amount_max_text]
		
		&"Script":
			var instance_key: String = menu_data[&"Instance_Key"]
			var expression: String = menu_data[&"Expression"]
			text += instance_key
			text += ": %s" % expression
	
	_a_Main.set_base_args(text)

func _update_branches() -> void:
	var base_min_size: Vector2 = _a_Main.get_base_margin_min_size()
	var margin: float = _get_main_arg_margin()
	var else_branch: bool = _a_data[&"Else_Branch"]
	_a_Else.set_base_margin_min_size(Vector2(margin, base_min_size.y))
	_a_Else.set_visible(else_branch)
	
	if !_is_branch_used(_a_process_branch_idx):
		swap_process(0)
	
	for child: DebugCommandEditorBranchBase in _a_Branches.get_children():
		var process_margin: Control = child.get_process_margin_instance()
		process_margin.custom_minimum_size.x = margin
		child.set_collapse_visible(true)
	_a_End.set_left_margin(margin)
