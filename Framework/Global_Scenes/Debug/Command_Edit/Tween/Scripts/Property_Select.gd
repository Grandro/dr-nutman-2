extends FWDebugValueSelectOptions
class_name FWDebugCommandEditCommandTweenPropertySelect

var _a_object: Node
var _a_comp: String

func update_options() -> void:
	super()
	
	var instance: Node = _a_object.comph().get_comp(_a_comp)
	var i: int = 0
	for args: Dictionary in instance.get_property_list():
		var usage: int = args[&"usage"]
		if !Debug.is_usage_for_editor(usage):
			continue
		
		var property: StringName = args[&"name"]
		var curr_value: Variant = instance.get(property)
		var type: int = typeof(curr_value)
		if !Debug.is_type_tween_supported(type):
			continue
		
		_a_option_idxs[property] = i
		_a_Value.add_item(property)
		_a_Value.set_item_metadata(i, property)
		
		i += 1

func set_object(p_object: Node) -> void:
	_a_object = p_object

func set_comp(p_comp: String) -> void:
	_a_comp = p_comp
