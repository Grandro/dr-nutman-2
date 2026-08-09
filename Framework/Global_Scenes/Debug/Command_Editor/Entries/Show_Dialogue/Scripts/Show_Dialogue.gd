extends FWDebugCommandEditorEntryCommand
class_name FWDebugCommandEditorEntryShowDialogue

# Breakable: [&"Key"][&"Value"]
#			 [&"Start_Idx"][&"Value"]
#			 [&"End_Idx"][&"Value"]
func _update_warnings_add() -> void:
	var key_type: StringName = _a_data[&"Key_Type"][&"Value"]
	var key: StringName = _a_data[&"Key"][&"Value"]
	var dialogues_data: Dictionary = Databases.get_global_map_data(&"Dialogues", key_type)
	if dialogues_data.has(key):
		var dialogue_data: Dictionary = dialogues_data[key][&"Data"]
		var max_idx: int = dialogue_data.size() - 1
		
		var start_idx: int = _a_data[&"Start_Idx"][&"Value"]
		if start_idx > max_idx:
			var value_keys: Array = [&"Start_Idx", &"Value"]
			var args: WarningArgsInt = WarningArgsInt.new(start_idx, value_keys, 0, max_idx)
			_a_warnings.push_back(args)
		
		var end_idx: int = _a_data[&"End_Idx"][&"Value"]
		if end_idx > max_idx:
			var value_keys: Array = [&"End_Idx", &"Value"]
			var args: WarningArgsInt = WarningArgsInt.new(end_idx, value_keys, -1, max_idx)
			_a_warnings.push_back(args)
	else:
		var value_keys: Array = [&"Key", &"Value"]
		var args: WarningArgsStringName = WarningArgsStringName.new(key, value_keys)
		_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var key_type_text: String = _get_display_text(_a_data[&"Key_Type"])
	var key_text: String = _get_display_text(_a_data[&"Key"])
	var process_type_text: String = _get_display_text(_a_data[&"Process_Type"])
	var start_idx_text: String = _get_display_text(_a_data[&"Start_Idx"])
	var end_idx_text: String = _get_display_text(_a_data[&"End_Idx"])
	var layer_text: String = _get_display_text(_a_data[&"Layer"])
	var fade_out: bool = _a_data[&"Fade_Out"][&"Value"]
	
	var text: String = key_type_text
	text += ", %s" % key_text
	text += ", %s" % process_type_text
	text += ", %s" % start_idx_text
	text += ", %s" % end_idx_text
	text += ", %s" % layer_text
	if fade_out:
		text += ", %s" % tr(&"FW_DEBUG_CUTSCENES_FADE_OUT")
	_a_Main.set_base_args(text)
