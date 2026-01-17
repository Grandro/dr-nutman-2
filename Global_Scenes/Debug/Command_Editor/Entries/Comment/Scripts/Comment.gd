extends DebugCommandEditorEntryCommand
class_name DebugCommandEditorEntryComment

# Breakable:
func _update_display_main_args() -> void:
	super()
	
	var text: Array = _a_data[&"Text"]
	for wrapped_text: PackedStringArray in text:
		for text_line: String in wrapped_text:
			_instantiate_main_arg(text_line, _e_color)
