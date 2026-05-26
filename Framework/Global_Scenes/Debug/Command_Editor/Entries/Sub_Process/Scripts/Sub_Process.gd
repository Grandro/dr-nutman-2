extends FWDebugCommandEditorEntryBranch
class_name FWDebugCommandEditorEntrySubProcess

# Breakable:
func _update_display_main_base_args() -> void:
	var id_text: String = _get_display_text(_a_data[&"ID"])
	_a_Main.set_base_args(id_text)

func _update_branches() -> void:
	var margin: float = _get_main_arg_margin()
	var process_margin: Control = _a_Main.get_process_margin_instance()
	process_margin.custom_minimum_size.x = margin
	_a_Main.set_collapse_visible(true)
	_a_End.set_left_margin(margin)

func get_cutscene_data() -> Array[Dictionary]:
	var save_data: Dictionary = get_save_data()
	var data: Array[Dictionary] = [save_data]
	
	return data
