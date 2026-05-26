extends FWDebugValueSelectOptions
class_name FWDebugCompSelect

var _a_object: Node

func update_options() -> void:
	_clear_options()
	
	var comps: Dictionary[StringName, Node] = _a_object.comph().get_comps()
	var comp_keys: Array[StringName] = comps.keys()
	for i: int in comp_keys.size():
		var comp: StringName = comp_keys[i]
		_a_option_idxs[comp] = i
		_a_Value.add_item(comp)
		_a_Value.set_item_metadata(i, comp)

func set_object(p_object: Node) -> void:
	_a_object = p_object
