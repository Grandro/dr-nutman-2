extends DebugValueEditTypeVector2
class_name DebugValueEditTypeVector3

@onready var _a_Z_Value: DebugFloatEdit = get_node("VBox/Z/HBox/Value")

func _ready() -> void:
	super()
	_a_Z_Value.value_changed.connect(_on_value_changed)

func to_color(_p_color: Color) -> void:
	pass

func set_default_value() -> void:
	set_value(Vector3.ZERO)

func set_value(p_value) -> void:
	super(p_value)
	_a_Z_Value.set_value(p_value.z)

func get_value():
	var value = Vector3.ZERO
	value.x = _a_X_Value.get_value()
	value.y = _a_Y_Value.get_value()
	value.z = _a_Z_Value.get_value()
	
	return value

func set_value_editable(p_value_editable: bool) -> void:
	super(p_value_editable)
	_a_Z_Value.set_editable(p_value_editable)
