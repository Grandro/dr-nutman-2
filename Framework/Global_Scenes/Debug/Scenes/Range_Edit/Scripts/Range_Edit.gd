extends HBoxContainer
class_name FWDebugRangeEdit

signal min_value_changed(p_value: float)
signal max_value_changed(p_value: float)

@export var _e_min_value: int = 0
@export var _e_max_value: int = 100
@export var _e_curr_min_value: int = 0
@export var _e_curr_max_value: int = 0

@onready var _a_Min: FWDebugNumEdit = get_node("Min/Value")
@onready var _a_Max: FWDebugNumEdit = get_node("Max/Value")

func _ready() -> void:
	_a_Min.value_changed.connect(_on_Min_value_changed)
	_a_Max.value_changed.connect(_on_Max_value_changed)
	
	_a_Min.set_value(_e_curr_min_value)
	_a_Max.set_value(_e_curr_max_value)
	_a_Min.set_min(_e_min_value)
	_a_Min.set_max(_e_max_value)
	_a_Max.set_min(_e_min_value)
	_a_Max.set_max(_e_max_value)

func set_min_value(p_value: float) -> void:
	_a_Min.set_value(p_value)

func get_min_value() -> float:
	return _a_Min.get_value()

func set_max_value(p_value: float) -> void:
	_a_Max.set_value(p_value)

func get_max_value() -> float:
	return _a_Max.get_value()

func set_max_value_max(p_max_value: float) -> void:
	_a_Max.set_max(p_max_value)
	_a_Min.set_max(p_max_value)

func _on_Min_value_changed(p_value: float) -> void:
	var max_value: float = _a_Max.get_value()
	_a_Max.set_value(max(max_value, p_value))
	min_value_changed.emit(p_value)

func _on_Max_value_changed(p_value: float) -> void:
	var min_value: float = _a_Min.get_value()
	_a_Min.set_value(min(min_value, p_value))
	max_value_changed.emit(p_value)
