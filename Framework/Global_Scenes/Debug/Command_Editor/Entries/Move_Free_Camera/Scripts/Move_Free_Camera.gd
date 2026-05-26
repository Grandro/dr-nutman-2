extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryMoveFreeCamera

func add_res_data(p_res_data: Dictionary, p_args: Array = []) -> void:
	super(p_res_data, p_args)
	
	var end_object_key: StringName = &"$Free_Camera"
	var type: StringName = _a_data[&"Type"][&"Value"]
	if type == &"Object_To_Object":
		var change_camera: bool = _a_data[&"Change_Camera"][&"Value"]
		if change_camera:
			end_object_key = _a_data[&"End_Object"][&"Value"]
	p_res_data[&"$Free_Camera"][&"Object"] = end_object_key

# Breakable: [&"Start_Object"][&"Value"], [&"End_Object"][&"Value"]
func _update_warnings_add() -> void:
	super()
	
	var global_si: Global = Global.get_singleton(self, "Global")
	var start_object_key: StringName = _a_data[&"Start_Object"][&"Value"]
	var start_instance: Node = global_si.get_object(start_object_key)
	if !is_instance_valid(start_instance):
		var value_keys: Array = [&"Start_Object", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(start_object_key, value_keys)
		_a_warnings.push_back(args)
	
	var end_object_key: StringName = _a_data[&"End_Object"][&"Value"]
	var end_instance: Node = global_si.get_object(end_object_key)
	if !is_instance_valid(end_instance):
		var value_keys: Array = [&"End_Object", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(end_object_key, value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var type: StringName = _a_data[&"Type"][&"Value"]
	var interpolate: bool = _a_data[&"Interpolate"][&"Value"]
	
	var text: String = ""
	match type:
		&"Move_Route":
			if interpolate:
				var speed_text: String = _get_display_text(_a_data[&"Speed"])
				var trans_type_text: String = _get_display_text(_a_data[&"Trans_Type"])
				var ease_type_text: String = _get_display_text(_a_data[&"Ease_Type"])
				var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
				text += "%s" % speed_text
				text += ", %s" % trans_type_text
				text += ", %s" % ease_type_text
				if wait_finish:
					text += " (%s)" % tr(&"WAIT")
			else:
				var nav_mesh_path_points: Dictionary = _a_data[&"Gen_Path"][&"Nav_Mesh_Path_Points"]
				if nav_mesh_path_points.is_empty():
					text += "-"
				else:
					var point: Variant = nav_mesh_path_points[-1]
					text += str(point)
		
		&"Object_To_Object":
			var end_object_text: String = _get_display_text(_a_data[&"End_Object"])
			if interpolate:
				var start_object_text: String = _get_display_text(_a_data[&"Start_Object"])
				var speed_text: String = _get_display_text(_a_data[&"Speed"])
				var trans_type_text: String = _get_display_text(_a_data[&"Trans_Type"])
				var ease_type_text: String = _get_display_text(_a_data[&"Ease_Type"])
				var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
				text += "%s - %s" % [start_object_text, end_object_text]
				text += ", %s" % speed_text
				text += ", %s" % trans_type_text
				text += ", %s" % ease_type_text
				if wait_finish:
					text += " (%s)" % tr(&"WAIT")
			else:
				text += end_object_text
		
		&"Object_To_Point":
			var point_selected: bool = _a_data[&"Point"][&"Selected"]
			if interpolate:
				var start_object_text: String = _get_display_text(_a_data[&"Start_Object"])
				text += "%s - " % start_object_text
			
			if point_selected:
				var point_text: String = _get_display_text(_a_data[&"Point"])
				text += str(point_text)
			else:
				text += "-"
			
			if interpolate:
				var speed_text: String = _get_display_text(_a_data[&"Speed"])
				var trans_type_text: String = _get_display_text(_a_data[&"Trans_Type"])
				var ease_type_text: String = _get_display_text(_a_data[&"Ease_Type"])
				var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
				text += ", %s" % speed_text
				text += ", %s" % trans_type_text
				text += ", %s" % ease_type_text
				if wait_finish:
					text += " (%s)" % tr(&"WAIT")
	_a_Main.set_base_args(text)

func _update_display_main_args() -> void:
	super()
	
	var type: String = _a_data[&"Type"][&"Value"]
	var interpolate: bool = _a_data[&"Interpolate"][&"Value"]
	match type:
		&"Move_Route":
			if interpolate:
				var nav_mesh_path_points: Dictionary = _a_data[&"Gen_Path"][&"Nav_Mesh_Path_Points"]
				for nav_mesh_path_point: Variant in nav_mesh_path_points:
					_instantiate_main_arg(str(nav_mesh_path_point), _e_color)
