extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryDisableObject

func _update_display_main_base_args() -> void:
	var is_disabled: bool = _a_data[&"Disable"][&"Value"]
	var object_text: String = _get_display_text(_a_data[&"Object"])
	
	var text: String = ""
	if is_disabled:
		text += tr(&"DEBUG_CUTSCENES_DISABLE")
	else:
		text += tr(&"DEBUG_CUTSCENES_ENABLE")
	text += " %s" % object_text
	_a_Main.set_base_args(text)
