extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntrySetAvoidance

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	var avoidance_text: String = _get_display_text(_a_data[&"Avoidance"])
	
	var text: String = object_text
	text += ", %s" % avoidance_text
	_a_Main.set_base_args(text)
