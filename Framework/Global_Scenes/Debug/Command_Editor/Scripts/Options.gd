extends FWContextMenu
class_name FWDebugCommandEditorOptions

func _ready() -> void:
	super()
	set_option_disabled(&"Paste", true)
