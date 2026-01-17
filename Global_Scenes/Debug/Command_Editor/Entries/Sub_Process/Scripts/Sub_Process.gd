extends DebugCommandEditorEntryBranch
class_name DebugCommandEditorEntrySubProcess

# Breakable:
func _update_display_main_base_args() -> void:
	var id_text: String = _get_display_text(_a_data[&"ID"])
	_a_Main.set_base_args(id_text)

func _update_branches() -> void:
	var margin: float = _get_main_arg_margin()
	_a_Main.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func get_cutscene_data() -> Dictionary:
	return get_save_data()
