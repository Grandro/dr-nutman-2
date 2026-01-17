extends VBoxContainer
class_name DebugValueEditTypeVector2

signal value_changed(p_value: Vector2)

@onready var _a_Select: Button = get_node("Select")
@onready var _a_VBox: VBoxContainer = get_node("VBox")
@onready var _a_X_Value: DebugFloatEdit = get_node("VBox/X/HBox/Value")
@onready var _a_Y_Value: DebugFloatEdit = get_node("VBox/Y/HBox/Value")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_X_Value.value_changed.connect(_on_value_changed)
	_a_Y_Value.value_changed.connect(_on_value_changed)

func expand(_p_depth: int) -> void:
	_a_VBox.show()

func delete() -> void:
	queue_free()

func to_color(_p_color: Color) -> void:
	pass

func set_default_value() -> void:
	set_value(Vector2.ZERO)

func set_value(p_value) -> void:
	_a_X_Value.set_value(p_value.x)
	_a_Y_Value.set_value(p_value.y)

func get_value():
	var value: Vector2 = Vector2.ZERO
	value.x = _a_X_Value.get_value()
	value.y = _a_Y_Value.get_value()
	
	return value

func set_value_editable(p_value_editable: bool) -> void:
	_a_X_Value.set_editable(p_value_editable)
	_a_Y_Value.set_editable(p_value_editable)

func set_expanded(p_expanded: bool) -> void:
	_a_VBox.set_visible(p_expanded)

func _on_Select_pressed() -> void:
	_a_VBox.visible = !_a_VBox.visible

func _on_value_changed(_p_value: float) -> void:
	var value: Variant = get_value()
	value_changed.emit(value)
	
	_a_Select.set_text(str(value))
