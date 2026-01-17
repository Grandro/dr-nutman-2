@tool
extends SpinBox
class_name DebugNumEdit

func _ready() -> void:
	var line_edit: LineEdit = get_line_edit()
	line_edit.set(&"custom_constants/minimum_spaces", 0)
