extends DebugValueSelect
class_name DebugValueSelectSlider

signal value_changed(p_value: float)

@export var _e_display_value: bool = false

@onready var _a_Value: HSlider = get_node("Value")
@onready var _a_Display: Label = get_node("Display")

func _ready() -> void:
	super()
	_a_Value.value_changed.connect(_on_Value_value_changed)
	
	var value: float = _a_Value.get_value()
	_a_Display.set_text(str(value))
	_a_Display.set_visible(_e_display_value)

func get_value() -> float:
	return _a_Value.get_value()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.get_value()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_value(p_data[&"Value"])

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_editable(!p_toggled)

func _on_Value_value_changed(p_value: float) -> void:
	_a_Display.set_text(str(p_value))
	value_changed.emit(p_value)
