extends FWDebugCommandEditorEntryBase
class_name FWDebugCommandEditorEntryCommand

signal arg_focus_entered()
signal arg_right_clicked(p_pos: Vector2)
signal warning_pressed(p_pos: Vector2)
signal mark_changed(p_mark: StringName)

@export var _e_color: Color = Color.WHITE

var _a_Arg_Entry_Scene: PackedScene = preload("uid://dx2jb6i5c6i3t")

var _a_data: Dictionary = {}
var _a_args: Dictionary = {}
var _a_warnings: Array[WarningArgsBase] = []

func _ready() -> void:
	super()
	_a_Main.warning_pressed.connect(_on_Main_warning_pressed)

func connect_to_editor(p_editor: FWDebugCommandEditor) -> void:
	super(p_editor)
	arg_focus_entered.connect(p_editor._on_Entry_arg_focus_entered.bind(self))
	arg_right_clicked.connect(p_editor._on_Entry_arg_right_clicked.bind(self))
	warning_pressed.connect(p_editor._on_Entry_warning_pressed.bind(self))
	mark_changed.connect(p_editor._on_Entry_mark_changed.bind(self))

func update_data(p_data: Dictionary) -> void:
	_a_data = p_data
	
	update_warnings()
	update_display()

func update_warnings() -> void:
	_a_warnings.clear()
	
	_update_warnings_add()
	
	var show_warning: bool = !_a_warnings.is_empty()
	_a_Main.set_warning_visible(show_warning)

func update_display() -> void:
	_update_display_main_base_desc()
	_update_display_main_base_args()
	_update_display_main_args()
	
	_a_Main.set_base_desc_modulate(_e_color)
	_a_Main.set_base_args_modulate(_e_color)

func _update_warnings_add() -> void:
	pass

func _update_warnings_add_expression(p_data: Dictionary, p_value_keys: Array) -> void:
	var instance_key: StringName = p_data[&"Instance_Key"]
	var type: StringName = p_data[&"Type"]
	var instance: Node
	match type:
		&"Object":
			var global_si: Global = Global.get_singleton(self, "Global")
			instance = global_si.get_object(instance_key)
		&"Singleton":
			instance = Global.get_singleton(self, instance_key)
		&"Curr_Scene":
			var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
			instance = scene_manager_si.get_curr_scene_instance()
	
	if !is_instance_valid(instance):
		var args: WarningArgsStringName = WarningArgsStringName.new(instance_key, p_value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_desc() -> void:
	var base_desc_loc_id: StringName = "FW_DEBUG_CUTSCENES_COMMANDS_%s" % _a_command.to_upper()
	_a_Main.set_base_desc("%s: " % tr(base_desc_loc_id))

func _update_display_main_base_args() -> void:
	pass

func _update_display_main_args() -> void:
	for child: FWDebugCommandEditorArgEntry in _a_Main.get_args_children():
		child.queue_free()

func _instantiate_main_arg(p_desc: String, p_color: Color) -> void:
	var margin: float = _get_main_arg_margin()
	var instance: FWDebugCommandEditorArgEntry = _a_Arg_Entry_Scene.instantiate()
	instance.focus_entered.connect(_on_Arg_focus_entered)
	instance.gui_input.connect(_on_Arg_gui_input)
	instance.set_left_margin.call_deferred(margin)
	instance.set_hbox_modulate.call_deferred(p_color)
	instance.set_desc.call_deferred(p_desc)
	
	_a_Main.add_args_child(instance)

func set_args(p_args: Dictionary) -> void:
	_a_args = p_args
	
	if _a_args.has(&"Mark"):
		set_mark(_a_args[&"Mark"])
	else:
		set_mark(&"Default")

func get_data() -> Dictionary:
	return _a_data

func get_cutscene_data() -> Array[Dictionary]:
	var save_data: Dictionary = get_save_data()
	var data: Array[Dictionary] = [save_data]
	
	return data

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Command"] = _a_command
	data[&"Data"] = _a_data.duplicate(true)
	data[&"Args"] = _a_args.duplicate(true)
	
	return data

func set_mark(p_mark: StringName) -> void:
	_a_Main.set_mark(p_mark)
	_a_args[&"Mark"] = p_mark
	mark_changed.emit(p_mark)

func get_entries_count(p_branch_idx: int = -1) -> int:
	var entries: Array[FWDebugCommandEditorEntryBase] = get_entries(p_branch_idx)
	var count: int = entries.size()
	
	return count

func get_entries(p_branch_idx: int = -1) -> Array[FWDebugCommandEditorEntryBase]:
	var entries: Array[FWDebugCommandEditorEntryBase] = []
	if p_branch_idx == -1:
		for branch: FWDebugCommandEditorBranchBase in _a_Branches.get_children():
			for entry: FWDebugCommandEditorEntryBase in branch.get_entries():
				entries.push_back(entry)
	else:
		var branch: FWDebugCommandEditorBranchBase = _a_Branches.get_child(p_branch_idx)
		for entry: FWDebugCommandEditorEntryBase in branch.get_entries():
			entries.push_back(entry)
	
	return entries

func get_branch_entry(p_branch_idx: int, p_idx: int) -> FWDebugCommandEditorEntryBase:
	var branch: FWDebugCommandEditorBranchBase = _a_Branches.get_child(p_branch_idx)
	var entry: FWDebugCommandEditorEntryBase = branch.get_entry(p_idx)
	
	return entry

func get_warnings() -> Array[WarningArgsBase]:
	return _a_warnings

func _get_main_arg_margin() -> float:
	var desc_pos: Vector2 = _a_Main.get_base_margin_min_size()
	var margin: float = desc_pos.x + 18.0
	
	return margin

func _get_display_text(p_data: Dictionary) -> String:
	var type: StringName = p_data[&"Type"]
	var display_text: String
	match type:
		&"Var": display_text = _get_var_display_text(p_data[&"Var"])
		&"Value": display_text = str(p_data[&"Value"])
	
	return display_text

func _on_Main_warning_pressed() -> void:
	var pos: Vector2 = _a_Main.get_warning_global_pos()
	warning_pressed.emit(pos)

func _on_Arg_focus_entered() -> void:
	arg_focus_entered.emit()

func _on_Arg_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Mouse_Right"):
		var pos: Vector2 = p_event.get_global_position()
		arg_right_clicked.emit(pos)

class WarningArgsBase:
	var _a_type: StringName
	var _a_value: Variant # Invalid value
	var _a_value_keys: Array # Dictionary keys to invalid value
	
	func _init(p_value: Variant, p_value_keys: Array):
		_a_value = p_value
		_a_value_keys = p_value_keys
	
	func get_type() -> StringName:
		return _a_type
	
	func get_value() -> Variant:
		return _a_value
		
	func get_value_keys() -> Array:
		return _a_value_keys

class WarningArgsInt extends WarningArgsBase:
	var _a_min: int # Min value
	var _a_max: int # Max value
	
	func _init(p_value: int, p_value_keys: Array, p_min: int, p_max: int):
		super(p_value, p_value_keys)
		_a_type = &"Int"
		_a_min = p_min
		_a_max = p_max
	
	func get_min() -> int:
		return _a_min
	
	func get_max() -> int:
		return _a_max

class WarningArgsString extends WarningArgsBase:
	func _init(p_value: String, p_value_keys: Array):
		super(p_value, p_value_keys)
		_a_type = &"String"

class WarningArgsStringName extends WarningArgsBase:
	func _init(p_value: StringName, p_value_keys: Array):
		super(p_value, p_value_keys)
		_a_type = &"String_Name"

class WarningArgsArray extends WarningArgsBase:
	func _init(p_value: Array, p_value_keys: Array):
		super(p_value, p_value_keys)
		_a_type = &"Array"

class WarningArgsRange extends WarningArgsInt:
	func _init(p_value: Variant, p_value_keys: Array, p_min: int, p_max: int):
		super(p_value, p_value_keys, p_min, p_max)
		_a_type = &"Range"

class WarningArgsFile extends WarningArgsBase:
	var _a_dir_path: String # File: Directory path which should be opened
	var _a_filters: PackedStringArray # File type filters
	
	func _init(p_value: String, p_value_keys: Array, p_dir_path: String, p_filters: PackedStringArray):
		super(p_value, p_value_keys)
		_a_type = &"File"
		_a_dir_path = p_dir_path
		_a_filters = p_filters
