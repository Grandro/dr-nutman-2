extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryChangeVisibility

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var is_visible_: bool = _a_data[&"Visible"][&"Value"]
	
	var text: String = ""
	if is_visible_:
		text += tr(&"FW_SHOW")
	else:
		text += tr(&"FW_HIDE")
	text += " %s" % object_text
	_a_Main.set_base_args(text)
