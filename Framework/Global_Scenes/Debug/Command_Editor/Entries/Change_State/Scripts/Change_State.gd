extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryChangeState

# Breakable: [&"Object"][&"Value"], [&"State"][&"Value"]
func _update_warnings_add() -> void:
	var instance: Node = _update_warnings_add_object()
	if instance != null:
		var states: Array[StringName] = instance.comph().call_comp("States", &"get_states")
		var state_key: StringName = _a_data[&"State"][&"Value"]
		if !states.has(state_key):
			var value_keys: Array = [&"State", &"Value"]
			var args: WarningArgsStringName = WarningArgsStringName.new(state_key, value_keys)
			_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var state_text: String = _get_display_text(_a_data[&"State"])
	
	var text: String = object_text
	text += ", %s" % state_text
	_a_Main.set_base_args(text)
