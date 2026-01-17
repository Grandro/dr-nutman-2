extends DebugFixWarningsEntryBase
class_name DebugFixWarningsEntryArray

@onready var _a_New_Value: DebugValueEdit = get_node("VBox/New/Value")

func _ready() -> void:
	super()
	_a_New_Value.value_changed.connect(_on_New_Value_value_changed)

func _on_New_Value_value_changed(p_value: Array) -> void:
	_a_new_value = p_value.duplicate()
