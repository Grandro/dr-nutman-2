extends DebugCommandEditorEntryObject
class_name DebugCommandEditorEntryTeleportObject

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var point_selected: bool = _a_data[&"Point"][&"Selected"]
	
	var text: String = object_text
	if point_selected:
		var point_text: String = _get_display_text(_a_data[&"Point"])
		text += " %s" % str(point_text)
	_a_Main.set_base_args(text)
