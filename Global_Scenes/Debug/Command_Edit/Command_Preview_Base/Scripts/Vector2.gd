extends HBoxContainer
class_name DebugCommandEditPreviewVector2

signal x_value_changed(p_value: float)
signal y_value_changed(p_value: float)

@export var _e_desc_loc_id: StringName = &""

@onready var _a_Desc: Label = get_node("Desc")
@onready var _a_X: DebugFloatEdit = get_node("X")
@onready var _a_Y: DebugFloatEdit = get_node("Y")

func _ready() -> void:
	_a_X.value_changed.connect(_on_X_value_changed)
	_a_Y.value_changed.connect(_on_Y_value_changed)
	
	_a_Desc.set_text(tr(_e_desc_loc_id))

func set_x_value(p_value: float) -> void:
	_a_X.set_value(p_value)

func set_y_value(p_value: float) -> void:
	_a_Y.set_value(p_value)

func get_value() -> Variant:
	var x = _a_X.get_value()
	var y = _a_Y.get_value()
	
	return Vector2(x, y)

func set_x_max(p_max: float) -> void:
	_a_X.set_max(p_max)

func set_y_max(p_max: float) -> void:
	_a_Y.set_max(p_max)

func _on_X_value_changed(p_value: float) -> void:
	x_value_changed.emit(p_value)

func _on_Y_value_changed(p_value: float) -> void:
	y_value_changed.emit(p_value)
