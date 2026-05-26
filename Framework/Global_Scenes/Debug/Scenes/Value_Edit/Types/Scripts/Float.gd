extends PanelContainer
class_name DebugValueEditTypeFloat

signal value_changed(p_value: float)

@onready var _a_Value: FWDebugFloatEdit = get_node("Value")

func _ready() -> void:
	_a_Value.value_changed.connect(_on_Value_value_changed)
	
	set_default_value()

func expand(_p_depth: int) -> void:
	pass

func delete() -> void:
	queue_free()

func to_color(_p_color: Color) -> void:
	pass

func set_default_value() -> void:
	set_value(0.0)

func set_value(p_value: float) -> void:
	_a_Value.set_value(p_value)

func get_value() -> float:
	return _a_Value.get_value()

func set_value_editable(p_value_editable: bool) -> void:
	_a_Value.set_editable(p_value_editable)

func set_expanded(_p_expanded: bool) -> void:
	pass

func _on_Value_value_changed(p_value: float) -> void:
	value_changed.emit(p_value)
