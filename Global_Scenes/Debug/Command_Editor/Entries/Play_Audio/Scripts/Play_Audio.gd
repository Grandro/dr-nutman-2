extends DebugCommandEditorEntryObject
class_name DebugCommandEditorEntryPlayAudio

# Breakable: [&"Audio"][&"Value"]
func _update_warnings_add() -> void:
	super()
	
	var stream_path: String = _a_data[&"Audio"][&"Value"]
	if !FileAccess.file_exists(stream_path):
		var value_keys: Array = [&"Audio", &"Value"]
		var dir_path: String = "res://Global_Resources/Audio"
		var filters: PackedStringArray = PackedStringArray(["*.ogg", "*.wav"])
		var args: WarningArgsFile = WarningArgsFile.new(stream_path, value_keys, dir_path, filters)
		_a_warnings.push_back(args)

func _update_display_main_base_args() -> void:
	var audio_type: String = _get_display_text(_a_data[&"Audio_Type"])
	var type: String = _get_display_text(_a_data[&"Type"])
	var stream_path: String = _a_data[&"Audio"][&"Value"]
	var wait_finish: bool = _a_data[&"Wait_Finish"][&"Value"]
	
	var text: String = audio_type
	text += ", %s" % type
	if !stream_path.is_empty():
		var file_name: String = stream_path.get_file()
		text += ", %s" % file_name
	else:
		text += ", -"
	
	if wait_finish:
		text += " (%s)" % tr(&"WAIT")
	_a_Main.set_base_args(text)
