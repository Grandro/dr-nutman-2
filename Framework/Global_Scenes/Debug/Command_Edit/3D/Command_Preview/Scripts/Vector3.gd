extends FWDebugCommandEditPreviewVector2
class_name FWDebugCommandEditPreviewVector3

signal z_value_changed(p_value: float)

@onready var _a_Z: FWDebugFloatEdit = get_node("Z")

func _ready() -> void:
	super()
	_a_Z.value_changed.connect(_on_Z_value_changed)

func set_z_value(p_value: float) -> void:
	_a_Z.set_value(p_value)

func get_value() -> Variant:
	var x: float = _a_X.get_value()
	var y: float = _a_Y.get_value()
	var z: float = _a_Z.get_value()
	return Vector3(x, y, z)

func set_z_max(p_max: float) -> void:
	_a_Z.set_max(p_max)

func _on_Z_value_changed(p_value: float) -> void:
	z_value_changed.emit(p_value)
