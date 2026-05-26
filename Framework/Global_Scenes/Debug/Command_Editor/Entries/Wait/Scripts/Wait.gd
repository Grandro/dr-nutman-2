extends FWDebugCommandEditorEntryCommand
class_name FWDebugCommandEditorEntryWait

# Breakable:
func _update_display_main_args() -> void:
	var time_text: String = _get_display_text(_a_data[&"Time"])
	var text: String = time_text
	text += " %s" % tr(&"SECONDS")
	_a_Main.set_base_args(text)
