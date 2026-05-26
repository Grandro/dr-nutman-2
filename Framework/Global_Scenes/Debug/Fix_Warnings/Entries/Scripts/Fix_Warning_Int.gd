extends FWDebugFixWarningsEntryBase
class_name FWDebugFixWarningsEntryInt

@onready var _a_New_Value: FWDebugNumEdit = get_node("VBox/New/Value")

func _ready() -> void:
	super()
	_a_New_Value.value_changed.connect(_on_New_Value_value_changed)
	
	var min_: int = _a_warning.get_min()
	var max_: int = _a_warning.get_max()
	_a_New_Value.set_min(min_)
	_a_New_Value.set_max(max_)
	_a_new_value = int(_a_New_Value.get_value())

func _on_New_Value_value_changed(p_value: float) -> void:
	_a_new_value = int(p_value)
