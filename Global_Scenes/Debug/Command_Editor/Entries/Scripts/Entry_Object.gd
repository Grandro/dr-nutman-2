extends DebugCommandEditorEntryCommand
class_name DebugCommandEditorEntryObject

func add_res_data(p_res_data: Dictionary, _p_args: Array = []) -> void:
	var key: StringName = _a_data[&"Object"][&"Value"]
	if !p_res_data[&"Objects"].has(key):
		p_res_data[&"Objects"][key] = {}
		p_res_data[&"Objects"][key][&"Properties"] = {}
		p_res_data[&"Objects"][key][&"Equipables"] = {}
	
	# Collect changed properties of objects
	var res_properties: Dictionary = p_res_data[&"Objects"][key][&"Properties"]
	var properties: Dictionary = _a_data[&"Object"][&"Properties"]
	for comp_key: StringName in properties:
		if !res_properties.has(comp_key):
			res_properties[comp_key] = {}
		for property: StringName in properties[comp_key]:
			res_properties[comp_key][property] = properties[comp_key][property]
	
	# Collect changed equipables of objects
	var res_equipables: Dictionary = p_res_data[&"Objects"][key][&"Equipables"]
	var equipables: Dictionary = _a_data[&"Object"][&"Equipables"]
	for group: StringName in equipables:
		res_equipables[group] = equipables[group]

# Breakable: [&"Object"][&"Value"]
func _update_warnings_add() -> void:
	_update_warnings_add_object()

func _update_warnings_add_object() -> Node:
	var object_key: StringName = _a_data[&"Object"][&"Value"]
	var global_si: Global = Global.get_singleton(self, "Global")
	var instance: Node = global_si.get_object(object_key)
	if instance == null:
		var value_keys: Array = [&"Object", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(object_key, value_keys)
		_a_warnings.push_back(args)
	
	return instance
