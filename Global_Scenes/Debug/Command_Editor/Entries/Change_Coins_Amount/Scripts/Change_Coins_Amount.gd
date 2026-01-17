extends DebugCommandEditorEntryCommand
class_name DebugCommandEditorEntryChangeCoinsAmount

# Breakable: 
func _update_display_main_base_args() -> void:
	var type: StringName = _a_data[&"Type"][&"Value"]
	var amount_text: String = _get_display_text(_a_data[&"Amount"])
	
	var text: String = "Coins"
	match type:
		&"Gain": text += " +"
		&"Lose": text += " -"
	text += str(amount_text)
	_a_Main.set_base_args(text)
