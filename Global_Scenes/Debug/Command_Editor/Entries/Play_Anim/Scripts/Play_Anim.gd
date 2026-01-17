extends DebugCommandEditorEntryObject
class_name DebugCommandEditorEntryPlayAnim

# Breakable: [&"Anim_Keep_Dir"][&"Value"]/[&"Anim_All"][&"Value"], [&"Object"][&"Value"]
func _update_warnings_add() -> void:
	var instance: Node = _update_warnings_add_object()
	if is_instance_valid(instance):
		var anim_list: PackedStringArray = instance.comph().call_comp("Anims", &"get_animation_list")
		var keep_dir: bool = _a_data[&"Keep_Dir"][&"Value"]
		var anim_name: String
		var type_key: StringName
		if keep_dir:
			anim_name = _a_data[&"Anim_Keep_Dir"][&"Value"]
			anim_name += "_%s" % instance.comph().call_comp("Movement", &"get_dir")
			type_key = &"Anim_Keep_Dir"
		else:
			anim_name = _a_data[&"Anim_All"][&"Value"]
			type_key = &"Anim_All"
		
		if !(anim_name in anim_list):
			var value_keys: Array = [type_key, &"Value"]
			var args: WarningArgsStringName = WarningArgsStringName.new(anim_name, value_keys)
			_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var backwards: bool = _a_data[&"Backwards"][&"Value"]
	var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
	var speed_text: String = _get_display_text(_a_data[&"Speed"])
	var keep_dir: bool = _a_data[&"Keep_Dir"][&"Value"]
	var anim_text: String
	if keep_dir:
		anim_text = _get_display_text(_a_data[&"Anim_Keep_Dir"])
	else:
		anim_text = _get_display_text(_a_data[&"Anim_All"])
	
	var text: String = object_text
	text += ", %s" % anim_text
	if backwards:
		text += ", %s" % tr(&"DEBUG_CUTSCENES_BACKWARDS")
	text += ", %s" % speed_text
	
	if wait_finish:
		text += " (%s)" % tr(&"WAIT")
	_a_Main.set_base_args(text)
