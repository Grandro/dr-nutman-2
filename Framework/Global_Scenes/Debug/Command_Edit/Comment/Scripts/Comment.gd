extends FWDebugCommandEditCommandBase
class_name FWDebugCommandEditCommandComment

@onready var _a_Text: TextEdit = get_node("Window/Contents/Margin/VBox/Text")

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	var text: Array = p_data[&"Text"]
	for i: int in text.size():
		var wrapped_text: PackedStringArray = text[i]
		var text_line: String = ""
		for sub_text: String in wrapped_text:
			text_line += sub_text
		if i < text.size() - 1:
			text_line += "\n"
		_a_Text.text += text_line

func _get_save_data() -> Dictionary:
	var data: Dictionary = {}
	var text: Array[PackedStringArray] = []
	var line_count: int = _a_Text.get_line_count()
	text.resize(line_count)
	for i: int in line_count:
		var wrapped_text: PackedStringArray = _a_Text.get_line_wrapped_text(i)
		text[i] = wrapped_text
	data[&"Text"] = text
	
	return data
