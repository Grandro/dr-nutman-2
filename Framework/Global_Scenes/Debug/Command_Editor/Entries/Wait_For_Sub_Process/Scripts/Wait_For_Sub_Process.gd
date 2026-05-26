extends FWDebugCommandEditorEntryCommand
class_name FWDebugCommandEditorEntryWaitForSubProcess

# Breakable:
func _update_display_main_args() -> void:
	var id_text: String = _get_display_text(_a_data[&"ID"])
	_a_Main.set_base_args(id_text)
