extends PanelContainer
class_name FWDebugValueEditTypeString

signal value_changed(p_value: String)

@onready var _a_Value: LineEdit = get_node("Value")

func _ready() -> void:
	_a_Value.text_changed.connect(_on_Value_text_changed)
	
	set_default_value()

func expand(_p_depth: int) -> void:
	pass

func to_color(_p_color: Color) -> void:
	pass

func delete() -> void:
	queue_free()

func set_default_value() -> void:
	set_value("")

func set_value(p_value: String) -> void:
	_a_Value.set_text(p_value)

func get_value() -> String:
	return _a_Value.get_text()

func set_value_editable(p_value_editable: bool) -> void:
	_a_Value.set_editable(p_value_editable)

func set_expanded(_p_expanded: bool) -> void:
	pass

func _on_Value_text_changed(p_text: String) -> void:
	value_changed.emit(p_text)
