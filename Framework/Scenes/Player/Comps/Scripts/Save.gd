extends FWCompSave
class_name FWCompPlayerSave

var _a_entity: FWPlayer3D
var _a_save_data: Dictionary

func init(p_entities: Array[Node]) -> void:
	super(p_entities)
	_a_entity = p_entities[-1]

func save_data(p_map_data: Dictionary) -> void:
	var key: StringName = _a_entity.get_key()
	var comps: Dictionary[StringName, Dictionary] = _a_entity.get_comps()
	var comps_data: Dictionary[StringName, FWCompData]; comps_data.assign(comps[key])
	var curr_comps: Dictionary[StringName, Node] = _a_entity_comph.get_comps()
	_save_comps(comps_data, curr_comps)
	
	var object_key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
	p_map_data[&"Objects"][object_key] = _a_save_data

func _save_comps(p_comps_data: Dictionary[StringName, FWCompData], p_curr_comps: Dictionary[StringName, Node]) -> void:
	for comp_key: String in p_comps_data:
		var instance: Node = p_curr_comps[comp_key]
		if instance == self:
			continue
		var comp_data: FWCompData = p_comps_data[comp_key]
		var group: StringName = comp_data.get_group()
		if !_a_save_data.has(comp_key):
			_a_save_data[comp_key] = {}
		_a_save_data[comp_key][group] = instance.get_save_data()

func _load_data(p_data: Dictionary) -> void:
	_a_save_data = p_data
	
	var key: StringName = _a_entity.get_key()
	var comps: Dictionary[StringName, Dictionary] = _a_entity.get_comps()
	var comps_data: Dictionary[StringName, FWCompData]; comps_data.assign(comps[key])
	var curr_comps: Dictionary[StringName, Node] = _a_entity_comph.get_comps()
	_load_comps(comps_data, curr_comps)

func _load_comps(p_comps_data: Dictionary[StringName, FWCompData], p_curr_comps: Dictionary[StringName, Node]) -> void:
	for comp_key: StringName in p_comps_data:
		if !_a_save_data.has(comp_key):
			continue
		var instance: Node = p_curr_comps[comp_key]
		if instance == self:
			continue
		var comp_data: FWCompData = p_comps_data[comp_key]
		var group: StringName = comp_data.get_group()
		if !_a_save_data[comp_key].has(group):
			continue
		instance.load_data(_a_save_data[comp_key][group])
