extends Indicator
class_name IndicatorButton

signal select_pressed()

@onready var _a_Select: Button = get_node("Select")

func _ready() -> void:
	super()
	_a_Select.pressed.connect(_on_Select_pressed)

func set_select_diabled(p_disabled: bool) -> void:
	_a_Select.set_disabled(p_disabled)

func _on_Select_pressed() -> void:
	select_pressed.emit()
