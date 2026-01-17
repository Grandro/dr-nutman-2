extends DebugCommandEditorEntryObject
class_name DebugCommandEditorEntryChangeCamera

func add_res_data(p_res_data: Dictionary, p_args: Array = []) -> void:
	super(p_res_data, p_args)
	
	var key: String = _a_data[&"Object"][&"Value"]
	if !key.is_empty():
		p_res_data[&"$Free_Camera"][&"Object"] = key

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	_a_Main.set_base_args(object_text)
