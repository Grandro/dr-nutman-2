extends FWExtensionBase
class_name FWPlayerShared

var _a_Operate: FWCompOperate

var _a_comps: Dictionary[StringName, Dictionary]
var _a_key: StringName

func ready() -> void:
	if Global.is_instance_in_game_world(_a_entity):
		var dialogue_system_si: Dialogue_System = Global.get_singleton(_a_entity, "Dialogue_System")
		var cutscene_system_si: Cutscene_System = Global.get_singleton(_a_entity, "Cutscene_System")
		dialogue_system_si.main_started.connect(_on_Dialogue_System_main_started)
		dialogue_system_si.main_completed.connect(_on_Dialogue_System_main_completed)
		cutscene_system_si.main_started.connect(_on_Cutscene_System_main_started)
		cutscene_system_si.main_completed.connect(_on_Cutscene_System_main_completed)

func init_comps(p_base_comps: Dictionary[StringName, Dictionary], p_override_comps: Dictionary[StringName, Dictionary]) -> void:
	_a_comps = p_base_comps.duplicate(true)
	for key: StringName in p_override_comps:
		for comp_key: StringName in p_override_comps[key]:
			_a_comps[key][comp_key] = p_override_comps[key][comp_key]

func _init_key(p_key: StringName) -> void:
	_a_Operate = _a_entity.get_node("Operate")
	
	match p_key:
		&"Dr_Nutman": _init_key_dr_nutman()

func _init_key_dr_nutman() -> void:
	var interaction: Node = _a_entity.get_node("Interactions/1")
	var interaction_system: FWPlayerCompInteractionSystem = _a_entity.get_node("Interaction_System")
	interaction.area_entered.connect(interaction_system._on_Interaction_area_entered)
	interaction.area_exited.connect(interaction_system._on_Interaction_area_exited)
	
	if Global.is_instance_in_game_world(_a_entity):
		var global_si: Global = Global.get_singleton(_a_entity, "Global")
		var camera: Node = _a_entity.get_node("Camera")
		global_si.set_curr_camera(camera)

func get_comps() -> Dictionary[StringName, Dictionary]:
	return _a_comps

func set_key(p_key: StringName) -> void:
	var global_si: Global = Global.get_singleton(_a_entity, "Global")
	global_si.save_data_object(_a_entity)
	_a_entity.comph().clear_comps()
	set_key_init(p_key)

func set_key_init(p_key: StringName) -> void:
	_a_key = p_key
	
	for comp_key: StringName in _a_comps[p_key]:
		var comp_data: FWCompData = _a_comps[p_key][comp_key]
		var scene: PackedScene = comp_data.get_scene()
		if scene == null:
			continue
		var instance: Node = scene.instantiate()
		_a_entity.add_child(instance)
	_a_entity.comph().register_comps()
	
	_init_key(p_key)

func get_key() -> StringName:
	return _a_key

func _on_Dialogue_System_main_started(_p_key: StringName) -> void:
	_a_Operate.disable()

func _on_Dialogue_System_main_completed() -> void:
	_a_Operate.enable()

func _on_Cutscene_System_main_started(_p_key: StringName) -> void:
	_a_Operate.disable()

func _on_Cutscene_System_main_completed() -> void:
	_a_Operate.enable()
