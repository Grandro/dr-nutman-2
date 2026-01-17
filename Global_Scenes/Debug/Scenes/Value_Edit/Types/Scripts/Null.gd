extends PanelContainer
class_name DebugValueEditTypeNull

signal value_changed(p_value: Variant)

@onready var _a_Value: Label = get_node("Value")

func _ready() -> void:
	set_default_value()

func expand(_p_depth: int) -> void:
	pass

func delete() -> void:
	queue_free()

func to_color(_p_color: Color) -> void:
	pass

func set_default_value() -> void:
	_a_Value.set_text("[null]")

func set_value(_p_value: Variant) -> void:
	pass

func get_value() -> Variant:
	return null

func set_value_editable(_p_value_editable: bool) -> void:
	pass

func set_expanded(_p_expanded: bool) -> void:
	pass
