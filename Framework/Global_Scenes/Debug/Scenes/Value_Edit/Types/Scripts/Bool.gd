extends PanelContainer
class_name FWDebugValueEditTypeBool

signal value_changed(p_value: bool)

@onready var _a_Value: CheckBox = get_node("Value")

func _ready() -> void:
	_a_Value.toggled.connect(_on_Value_toggled)
	
	set_default_value()

func expand(_p_depth: int) -> void:
	pass

func delete() -> void:
	queue_free()

func to_color(_p_color: Color) -> void:
	pass

func set_default_value() -> void:
	set_value(false)

func set_value(p_value: bool) -> void:
	_a_Value.set_pressed(p_value)

func get_value() -> bool:
	return _a_Value.is_pressed()

func set_value_editable(p_value_editable: bool) -> void:
	_a_Value.set_disabled(!p_value_editable)

func set_expanded(_p_expanded: bool) -> void:
	pass

func _on_Value_toggled(p_toggled: bool) -> void:
	value_changed.emit(p_toggled)
