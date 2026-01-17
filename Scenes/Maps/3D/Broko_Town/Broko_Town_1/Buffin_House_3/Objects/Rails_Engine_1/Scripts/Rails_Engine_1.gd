extends Static3DObject
class_name ObjectRailsEngine1

@export var _e_rails: Node3DObject = null
@export var _e_left_force: float = -1.0
@export var _e_right_force: float = 1.0
@export var _e_left_pushed: bool = false
@export var _e_right_pushed: bool = false

@onready var _a_Left: ObjectPressurePlateBase = get_node("Left")
@onready var _a_Right: ObjectPressurePlateBase = get_node("Right")

var _a_left_pushed: bool = false
var _a_right_pushed: bool = false
var _a_total_force: float = 0.0

func _ready() -> void:
	_a_Left.pushed.connect(_on_Pressure_Plate_pushed.bind(&"Left"))
	_a_Left.released.connect(_on_Pressure_Plate_released.bind(&"Left"))
	_a_Right.pushed.connect(_on_Pressure_Plate_pushed.bind(&"Right"))
	_a_Right.released.connect(_on_Pressure_Plate_released.bind(&"Right"))
	_a_Left.remove_from_group(&"Object")
	_a_Right.remove_from_group(&"Object")
	
	_a_left_pushed = _e_left_pushed
	_a_right_pushed = _e_right_pushed
	
	if _e_left_pushed:
		_a_Left.set_state(&"Pushed")
		_a_Left.set_locked(true)
	if _e_right_pushed:
		_a_Right.set_state(&"Pushed")
		_a_Right.set_locked(true)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Left"] = _a_Left.get_save_data()
	data[&"Right"] = _a_Right.get_save_data()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Left.load_data(p_data[&"Left"])
	_a_Right.load_data(p_data[&"Right"])

func _on_Pressure_Plate_pushed(p_type: StringName) -> void:
	match p_type:
		&"Left": _a_total_force += _e_left_force
		&"Right": _a_total_force += _e_right_force
	_e_rails.set_rail_cars_force(_a_total_force)

func _on_Pressure_Plate_released(p_type: StringName) -> void:
	match p_type:
		&"Left": _a_total_force -= _e_left_force
		&"Right": _a_total_force -= _e_right_force
	_e_rails.set_rail_cars_force(_a_total_force)
