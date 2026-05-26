extends FWDebugValueSelect
class_name FWDebugValueSelectEdit

signal value_changed(p_value: Variant)

@export var _e_data: FWValueEditData

@onready var _a_Value: FWDebugValueEdit = get_node("Value")

func _ready() -> void:
	super()
	_a_Value.value_changed.connect(_on_Value_value_changed)
	_a_Value.set_data(_e_data)

func expand(p_depth: int) -> void:
	_a_Value.expand(p_depth)

func set_value(p_value: Variant) -> void:
	_a_Value.set_value(p_value)

func get_value() -> Variant:
	return _a_Value.get_value()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.get_value()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_value(p_data[&"Value"])

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_type_editable(!p_toggled)
	_a_Value.set_value_editable(!p_toggled)

func _on_Value_value_changed(p_value: Variant) -> void:
	value_changed.emit(p_value)
