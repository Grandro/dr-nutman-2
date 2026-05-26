extends FWDebugCommandEditCommandBase
class_name FWDebugCommandEditCommandScript

@onready var _a_Expression: FWDebugExpressionBase = get_node("Window/Contents/Margin/VBox/Expression")

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	_a_Expression.update_instances()
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data: Dictionary) -> void:
	_a_Expression.load_data_init()

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	_a_Expression.load_data(p_data)

func _get_save_data() -> Dictionary:
	return _a_Expression.get_save_data()
