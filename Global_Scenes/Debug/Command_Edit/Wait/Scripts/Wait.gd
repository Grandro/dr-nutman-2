extends DebugCommandEditCommandBase
class_name DebugCommandEditCommandWait

@onready var _a_Time: DebugValueSelectFloat = get_node("Window/Contents/Margin/VBox/Time")

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()

func open(p_instance: DebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data: Dictionary) -> void:
	_a_Time.load_data_init()

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	_a_Time.load_data(p_data[&"Time"])

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Time"] = _a_Time.get_save_data()
	
	return data
