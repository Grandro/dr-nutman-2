extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryTween

# Breakable: [&"Object"][&"Value"], [&"Comp"][&"Value"], [&"Property"][&"Value"]
func _update_warnings_add() -> void:
	var object: Node = _update_warnings_add_object()
	if is_instance_valid(object):
		var comp: String = _a_data[&"Comp"][&"Value"]
		if !object.comph().has_comp(comp):
			var value_keys: Array = [&"Comp", &"Value"]
			var args: WarningArgsString = WarningArgsString.new(comp, value_keys)
			_a_warnings.push_back(args)
		else:
			var property: String = _a_data[&"Property"][&"Value"]
			var instance: Node = object.comph().get_comp(comp)
			if !(property in instance):
				var value_keys: Array = [&"Property", &"Value"]
				var args: WarningArgsString = WarningArgsString.new(property, value_keys)
				_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var comp_text: String = _get_display_text(_a_data[&"Comp"])
	var property_text: String = _get_display_text(_a_data[&"Property"])
	var interpolate: bool = _a_data[&"Interpolate"][&"Value"]
	var end_value_text: String = _get_display_text(_a_data[&"End_Value"])
	
	var text: String = object_text
	text += ": %s: %s" % [comp_text, property_text]
	if interpolate:
		var start_value_text: String = _get_display_text(_a_data[&"Start_Value"])
		var duration_text: String = _get_display_text(_a_data[&"Duration"])
		var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
		
		text += ", %s - %s" % [start_value_text, end_value_text]
		text += ", %s" % str(duration_text)
		if wait_finish:
			text += " (%s)" % tr(&"WAIT")
	else:
		text += ", %s" % end_value_text
	_a_Main.set_base_args(text)
