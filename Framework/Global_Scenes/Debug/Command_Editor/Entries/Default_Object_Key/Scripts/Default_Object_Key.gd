extends FWDebugCommandEditorEntryObject
class_name FWDebugCommandEditorEntryDefaultObjectKey

func add_res_data(p_res_data: Dictionary, p_args: Array = []) -> void:
	super(p_res_data, p_args)
	
	var key: String = _a_data[&"Object"][&"Value"]
	p_res_data[&"Default_Object"] = key

func _update_display_main_base_args() -> void:
	var object_text: String = _get_display_text(_a_data[&"Object"])
	_a_Main.set_base_args(object_text)
