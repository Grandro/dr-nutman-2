extends ContextMenu
class_name DebugCommandEditorOptions

func _ready() -> void:
	super()
	set_option_disabled(&"Paste", true)
