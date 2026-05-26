extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryJump

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var point_selected: bool = _a_data[&"Point"][&"Selected"]
	var point_text: String = _get_display_text(_a_data[&"Point"])
	var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
	
	var text: String = object_text
	if point_selected:
		text += " %s" % str(point_text)
	if wait_finish:
		text += " (%s)" % tr(&"WAIT")
	_a_Main.set_base_args(text)
