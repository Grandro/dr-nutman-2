extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntrySetMoveRoute

# Breakable: [&"Object"][&"Value"], [&"State"][&"Value"]
func _update_warnings_add() -> void:
	var instance: Node = _update_warnings_add_object()
	if is_instance_valid(instance):
		var states: Array[StringName] = instance.comph().call_comp("States", &"get_states")
		var state_key: StringName = _a_data[&"State"][&"Value"]
		if !states.has(state_key):
			var value_keys: Array = [&"State", &"Value"]
			var args: WarningArgsStringName = WarningArgsStringName.new(state_key, value_keys)
			_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var state_text: String = _get_display_text(_a_data[&"State"])
	var speed_text: String = _get_display_text(_a_data[&"Speed"])
	var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
	
	var text: String = object_text
	text += ", %s" % state_text
	text += ", %s" % speed_text
	if wait_finish:
		text += " (%s)" % tr(&"WAIT")
	_a_Main.set_base_args(text)

func _update_display_main_args() -> void:
	super()
	
	var nav_mesh_path_points: Dictionary = _a_data[&"Gen_Path"][&"Nav_Mesh_Path_Points"]
	for nav_mesh_path_point: Variant in nav_mesh_path_points:
		_instantiate_main_arg(str(nav_mesh_path_point), _e_color)
