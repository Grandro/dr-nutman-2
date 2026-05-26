extends Node
class_name FWCompSave

var _a_entity_comph: FWCompHandler = null

func init(p_entities: Array[Node]) -> void:
	_a_entity_comph = p_entities[-1].comph()
	_a_entity_comph.pre_comps_registered.connect(_on_Comp_Handler_pre_comps_registered)
	tree_exiting.connect(_on_tree_exiting)

func save_data(p_map_data: Dictionary) -> void:
	var data: Dictionary = {}
	var comps: Dictionary[StringName, Node] = _a_entity_comph.get_comps()
	for key: StringName in comps:
		var instance: Node = comps[key]
		if instance == self:
			continue
		data[key] = instance.get_save_data()
	
	var object_key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
	p_map_data[&"Objects"][object_key] = data

func _load_data_init() -> void:
	var comps: Dictionary[StringName, Node] = _a_entity_comph.get_comps()
	for instance: Node in comps.values():
		if instance == self:
			continue
		instance.load_data_init()

func _load_data(p_data: Dictionary) -> void:
	var comps: Dictionary[StringName, Node] = _a_entity_comph.get_comps()
	for key: StringName in comps:
		var instance: Node = comps[key]
		if instance == self:
			continue
		instance.load_data(p_data[key])

func _on_Comp_Handler_pre_comps_registered() -> void:
	if !Global.is_instance_in_game_world(self):
		return
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var map_data: Dictionary = global_si.get_saved_map_data()
	if map_data.is_empty():
		_load_data_init()
		return
	
	var object_key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
	if map_data[&"Objects"].has(object_key):
		_load_data(map_data[&"Objects"][object_key])
	else:
		_load_data_init()

func _on_tree_exiting() -> void:
	_a_entity_comph.pre_comps_registered.disconnect(_on_Comp_Handler_pre_comps_registered)
