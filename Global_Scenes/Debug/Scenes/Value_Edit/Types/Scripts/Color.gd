extends PanelContainer
class_name DebugValueEditTypeColor

signal value_changed(p_value: Color)

@onready var _a_Value: ColorPickerButton = get_node("Value")

func _ready() -> void:
	_a_Value.color_changed.connect(_on_color_changed)
	
	set_default_value()

func expand(_p_depth: int) -> void:
	pass

func delete() -> void:
	queue_free()

func to_color(_p_color: Color) -> void:
	pass

func set_default_value() -> void:
	set_value(Color.WHITE)

func set_value(p_value: Color) -> void:
	_a_Value.set_pick_color(p_value)

func get_value() -> Color:
	return _a_Value.get_pick_color()

func set_value_editable(p_value_editable: bool) -> void:
	_a_Value.set_disabled(!p_value_editable)

func set_expanded(_p_expanded: bool) -> void:
	pass

func _on_color_changed(p_color: Color) -> void:
	value_changed.emit(p_color)
