extends DebugCommandEditorEntryCommand
class_name DebugCommandEditorEntryScript

# Breakable: ["Instance_Key"]
func _update_warnings_add() -> void:
	_update_warnings_add_expression(_a_data, [&"Instance_Key"])

func _update_display_main_base_args() -> void:
	var instance_key: String = _a_data[&"Instance_Key"]
	var expression: String = _a_data[&"Expression"]
	var type: StringName = _a_data[&"Type"]
	var text: String = instance_key
	if type == &"Object":
		var comp: String = _a_data[&"Comp"]
		text += ": %s" % comp
	text += ": %s" % expression
	_a_Main.set_base_args(text)
