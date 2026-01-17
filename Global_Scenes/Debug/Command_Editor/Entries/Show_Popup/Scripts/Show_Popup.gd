extends DebugCommandEditorEntryObject
class_name DebugCommandEditorEntryShowPopup

# Breakable: [&"Type"][&"Value"]
func _update_warnings_add() -> void:
	super()
	
	var popup_types: Array[StringName] = Global.get_popup_types()
	var type: StringName = _a_data[&"Type"][&"Value"]
	if !popup_types.has(type):
		var value_keys: Array = [&"Type", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(type, value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var type_text: String = _get_display_text(_a_data[&"Type"])
	var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
	
	var text: String = object_text
	text += ", %s" % type_text
	if wait_finish:
		text += " (%s)" % tr(&"WAIT")
	_a_Main.set_base_args(text)
