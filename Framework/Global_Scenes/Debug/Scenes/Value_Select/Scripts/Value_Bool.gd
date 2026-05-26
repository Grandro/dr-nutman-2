extends FWDebugValueSelect
class_name FWDebugValueSelectBool

signal pressed()
signal toggled(p_toggled: bool)

@onready var _a_Value: CheckBox = get_node("Value")

func _ready() -> void:
	super()
	_a_Value.pressed.connect(_on_Value_pressed)
	_a_Value.toggled.connect(_on_Value_toggled)

func set_pressed(p_pressed: bool) -> void:
	_a_Value.set_pressed(p_pressed)

func is_pressed() -> bool:
	return _a_Value.is_pressed()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.is_pressed()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_pressed(p_data[&"Value"])

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_disabled(p_toggled)

func _on_Value_pressed() -> void:
	pressed.emit()

func _on_Value_toggled(p_toggled: bool) -> void:
	toggled.emit(p_toggled)
