extends FWDebugCommandEditCommandBase
class_name FWDebugCommandEditCommandExitCutscene

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/HBox/Cancel")
	super()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()
