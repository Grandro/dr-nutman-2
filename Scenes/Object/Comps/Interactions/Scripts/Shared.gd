extends ExtensionBase
class_name CompInteractionsShared

signal interacted()
signal interaction_activated(p_area: Node)
signal interaction_deactivated()

var _a_Default_Interaction: Node

var _a_entity_entity: Node
var _a_entity_entity_comph: CompHandler

var _a_allowed: bool = false
var _a_needs_look_at: bool = false
var _a_look_at_update: bool = false
var _a_look_at_activate: bool = false

func init(p_entity_entity: Node) -> void:
	_a_entity_entity = p_entity_entity
	_a_entity_entity_comph = p_entity_entity.comph()
	
	p_entity_entity.visibility_changed.connect(_on_Entity_Entity_visibility_changed)

func ready() -> void:
	_a_Default_Interaction = _a_entity.get_node("1")

func interaction(p_area: Node) -> void:
	var cutscene_args: Array[Array] = p_area.get_cutscene_args()
	if !cutscene_args.is_empty():
		_interaction_cutscene(p_area, cutscene_args)
	else:
		var dialogue_args: Array[StringName] = p_area.get_dialogue_args()
		if !dialogue_args.is_empty():
			_interaction_dialogue(p_area, dialogue_args)
	
	p_area.increase_interaction_count()
	interacted.emit()

func interaction_update(p_dir: StringName) -> void:
	if _a_look_at_update:
		_look_at_dir(p_dir)

func interaction_activate(p_area: Node, p_dir: StringName) -> void:
	var popup_type: StringName = p_area.get_popup_type()
	if popup_type != &"None":
		p_area.set_active(true)
		interaction_activated.emit(p_area)
	
	if _a_look_at_activate:
		_look_at_dir(p_dir)

func interaction_deactivate(p_area: Node) -> void:
	var popup_type: StringName = p_area.get_popup_type()
	if popup_type != &"None":
		p_area.set_active(false)
		interaction_deactivated.emit()

func increase_interaction_cutscene_args_idx(p_idx: int, p_value: int) -> void:
	var instance: Node = _a_entity.get_child(p_idx)
	instance.increase_cutscene_args_idx(p_value)

func increase_interaction_dialogue_args_idx(p_idx: int, p_value: int) -> void:
	var instance: Node = _a_entity.get_child(p_idx)
	instance.increase_dialogue_args_idx(p_value)

func _interaction_cutscene(p_area: Node, p_args: Array[Array]) -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(_a_entity, "Cutscene_System")
	var process_type: StringName = p_area.get_cutscene_process_type()
	var key_type: StringName = p_area.get_cutscene_key_type()
	var args_idx: int = p_area.get_cutscene_args_idx()
	var args: Array[StringName]; args.assign(p_args[args_idx])
	var key: StringName = args[0]
	var entry_key: StringName = args[1]
	cutscene_system_si.cutscene(key, entry_key, process_type, key_type)
	cutscene_system_si.set_cutscene_completed_cb(key, entry_key, _a_entity.CB_cutscene_completed)
	cutscene_system_si.set_cutscene_caller(key, entry_key, _a_entity_entity)

func _interaction_dialogue(p_area: Node, p_args: Array[StringName]) -> void:
	var dialogue_system_si: Dialogue_System = Global.get_singleton(_a_entity, "Dialogue_System")
	var process_type: StringName = p_area.get_dialogue_process_type()
	var fade_out: bool = p_area.get_dialogue_fade_out()
	var start_idx: int = p_area.get_dialogue_start_idx()
	var end_idx: int = p_area.get_dialogue_end_idx()
	var key_type: StringName = p_area.get_dialogue_key_type()
	var args_idx: int = p_area.get_dialogue_args_idx()
	var key: StringName = p_args[args_idx]
	dialogue_system_si.dialogue(key, _a_entity_entity, process_type, fade_out, start_idx, end_idx, key_type)
	dialogue_system_si.set_dialogue_layer(key, 10)
	dialogue_system_si.set_dialogue_completed_cb(key, _a_entity.CB_dialogue_completed)
	dialogue_system_si.set_dialogue_choice_selected_cb(key, _a_entity.CB_dialogue_choice_selected)

func _look_at_dir(p_dir: StringName) -> void:
	_a_entity_entity_comph.call_comp("Movement", &"set_dir", [p_dir])
	_a_entity_entity_comph.call_comp("Anims", &"update_anim")

func set_interaction_cutscene_args_idx(p_idx: int, p_args_idx: int) -> void:
	var instance: Node = _a_entity.get_child(p_idx)
	instance.set_cutscene_args_idx(p_args_idx)

func set_interaction_dialogue_args_idx(p_idx: int, p_args_idx: int) -> void:
	var instance: Node = _a_entity.get_child(p_idx)
	instance.set_dialogue_args_idx(p_args_idx)

func set_allowed(p_allowed: bool) -> void:
	_a_allowed = p_allowed

func get_allowed() -> bool:
	return _a_allowed

func set_needs_look_at(p_needs_look_at: bool) -> void:
	_a_needs_look_at = p_needs_look_at

func get_needs_look_at() -> bool:
	return _a_needs_look_at

func set_look_at_update(p_look_at_update: bool) -> void:
	_a_look_at_update = p_look_at_update

func get_look_at_update() -> bool:
	return _a_look_at_update

func set_look_at_activate(p_look_at_activate: bool) -> void:
	_a_look_at_activate = p_look_at_activate

func get_look_at_activate() -> bool:
	return _a_look_at_activate

func set_interaction_cutscene_args(p_idx: int, p_args: Array[Array]) -> void:
	var instance: Node = _a_entity.get_child(p_idx)
	instance.set_cutscene_args(p_args)

func set_interaction_dialogue_args(p_idx: int, p_args: Array[StringName]) -> void:
	var instance: Node = _a_entity.get_child(p_idx)
	instance.set_dialogue_args(p_args)

func get_default_interaction_pos() -> Variant:
	return _a_Default_Interaction.get_global_position()

func get_interaction_count(p_idx: int) -> int:
	var instance: Node = _a_entity.get_child(p_idx)
	var interaction_count: int = instance.get_interaction_count()
	
	return interaction_count

func get_entity_entity() -> Node:
	return _a_entity_entity

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Interactions"] = []
	for child: Node in _a_entity.get_children():
		var args: Dictionary = {}
		args[&"Type"] = child.get_type()
		args[&"Dirs"] = child.get_dirs()
		args[&"Use_Dir"] = child.get_use_dir()
		args[&"Use_Transform"] = child.get_use_transform()
		args[&"Popup_Type"] = child.get_popup_type()
		args[&"Cutscene_Args"] = child.get_cutscene_args()
		args[&"Cutscene_Args_Idx"] = child.get_cutscene_args_idx()
		args[&"Dialogue_Args"] = child.get_dialogue_args()
		args[&"Dialogue_Args_Idx"] = child.get_dialogue_args_idx()
		args[&"Interaction_Count"] = child.get_interaction_count()
		
		data[&"Interactions"].push_back(args)
	
	data[&"Allowed"] = get_allowed()
	data[&"Needs_Look_At"] = get_needs_look_at()
	data[&"Look_At_Update"] = get_look_at_update()
	data[&"Look_At_Activate"] = get_look_at_activate()
	
	return data

func load_data(p_data: Dictionary) -> void:
	for i: int in _a_entity.get_child_count():
		var child: Node = _a_entity.get_child(i)
		var args: Dictionary = p_data[&"Interactions"][i]
		child.set_type(args[&"Type"])
		child.set_dirs(args[&"Dirs"])
		child.set_use_dir(args[&"Use_Dir"])
		child.set_use_transform(args[&"Use_Transform"])
		child.set_popup_type(args[&"Popup_Type"])
		child.set_cutscene_args(args[&"Cutscene_Args"])
		child.set_cutscene_args_idx(args[&"Cutscene_Args_Idx"])
		child.set_dialogue_args(args[&"Dialogue_Args"])
		child.set_dialogue_args_idx(args[&"Dialogue_Args_Idx"])
		child.set_interaction_count(args[&"Interaction_Count"])
	
	_a_allowed = p_data[&"Allowed"]
	_a_needs_look_at = p_data[&"Needs_Look_At"]
	_a_look_at_update = p_data[&"Look_At_Update"]
	_a_look_at_activate = p_data[&"Look_At_Activate"]

func CB_cutscene_completed(_p_type: StringName, _p_key: StringName, _p_entry_key: StringName) -> void:
	pass

func CB_dialogue_completed(_p_key: StringName) -> void:
	pass

func CB_dialogue_choice_selected(_p_key: StringName, _p_value: Variant) -> void:
	pass

func _on_Entity_Entity_visibility_changed() -> void:
	var visible: bool = _a_entity_entity.is_visible()
	for child: Node in _a_entity.get_children():
		child.set_monitorable(visible)
