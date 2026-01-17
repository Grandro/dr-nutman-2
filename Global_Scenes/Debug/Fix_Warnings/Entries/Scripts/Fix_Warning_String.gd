extends DebugFixWarningsEntryBase
class_name DebugFixWarningsEntryString

@onready var _a_New_Value: LineEdit = get_node("VBox/New/Value")

func _ready() -> void:
	super()
	_a_New_Value.text_changed.connect(_on_New_Value_text_changed)

func _on_New_Value_text_changed(p_text: String) -> void:
	_a_new_value = p_text
