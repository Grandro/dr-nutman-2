extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryChangeDir

# Breakable: Look_At: Object: [&"Args"][&"Object"][&"Value"]
#			 Look_Away: Object: [&"Args"][&"Object"][&"Value"]
func _update_warnings_add() -> void:
	super()
	
	var type: StringName = _a_data[&"Type"][&"Value"]
	if type == &"Look_At" || type == &"Look_Away":
		var look_type: StringName = _a_data[&"Args"][&"Type"][&"Value"]
		if look_type == &"Object":
			var object_key: StringName = _a_data[&"Args"][&"Object"][&"Value"]
			var global_si: Global = Global.get_singleton(self, "Global")
			var instance: Node = global_si.get_object(object_key)
			if !is_instance_valid(instance):
				var value_keys: Array = [&"Args", &"Object", &"Value"]
				var args: WarningArgsStringName = WarningArgsStringName.new(object_key, value_keys)
				_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var type: StringName = _a_data[&"Type"][&"Value"]
	var args_text: String = " "
	var loc_id: StringName
	match type:
		&"Fixed_Dir":
			var dir_name: String = _get_display_text(_a_data[&"Args"][&"Dir"])
			args_text += "(%s)" % dir_name
		
		&"Look_Degrees":
			var degrees: String = _get_display_text(_a_data[&"Args"][&"Degrees"])
			args_text += "(%s°)" % degrees
		
		_:  # Look_At, Look_Away
			var arg_text: String
			var look_type: StringName = _a_data[&"Args"][&"Type"][&"Value"]
			match look_type:
				&"Object":
					arg_text = _get_display_text(_a_data[&"Args"][&"Object"])
				&"Point":
					var selected: bool = _a_data[&"Args"][&"Point"][&"Selected"]
					if selected:
						arg_text = _get_display_text(_a_data[&"Args"][&"Point"])
					else:
						arg_text = "-"
			
			loc_id = "FW_DEBUG_CUTSCENES_%s" % look_type.to_upper()
			args_text += "(%s, %s)" % [tr(loc_id), arg_text]
	
	loc_id = "FW_DEBUG_CUTSCENES_TYPE_%s" % type.to_upper()
	var text: String = object_text
	text += ", %s" % tr(loc_id)
	text += args_text
	_a_Main.set_base_args(text)
