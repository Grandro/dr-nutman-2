extends FWDebugValueSelect
class_name FWDebugValueSelectNum

signal value_changed(p_value: int)

@onready var _a_Value: FWDebugNumEdit = get_node("Value")

func _ready() -> void:
	super()
	_a_Value.value_changed.connect(_on_Value_value_changed)

func set_value_max(p_max: float) -> void:
	_a_Value.set_max(p_max)

func set_value(p_value: float) -> void:
	_a_Value.set_value(p_value)

func get_value() -> int:
	return int(_a_Value.get_value())

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = get_value()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_value(p_data[&"Value"])

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_editable(!p_toggled)

func _on_Value_value_changed(p_value: float) -> void:
	value_changed.emit(int(p_value))
