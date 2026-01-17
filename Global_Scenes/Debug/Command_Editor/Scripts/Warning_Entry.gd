extends ScrollContainer
class_name DebugCommandEditorWarningEntry

@onready var _a_Text: Label = get_node("Text")

func set_text(p_text: String) -> void:
	_a_Text.set_text(p_text)
