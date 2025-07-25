extends Node3D

@onready var _a_Stairway_2 = get_node("Stairway_2")
@onready var _a_Pressure_Plate_1 = get_node("Pressure_Plate_1")
@onready var _a_Pressure_Plate_2 = get_node("Pressure_Plate_2")
@onready var _a_Pressure_Plate_3 = get_node("Pressure_Plate_3")
@onready var _a_Power_Cable_1 = get_node("Power_Cable_1")
@onready var _a_Power_Cable_2 = get_node("Power_Cable_2")
@onready var _a_Power_Cable_3 = get_node("Power_Cable_3")
@onready var _a_Canvas_1 = get_node("Canvas_1")
@onready var _a_Canvas_2 = get_node("Canvas_2")
@onready var _a_Gate_1 = get_node("Gate_1")
@onready var _a_Gate_2 = get_node("Gate_2")
@onready var _a_Gate_3 = get_node("Gate_3")
@onready var _a_Projector_1 = get_node("Projector_1")

var _a_puzzle_1_solved = false
var _a_puzzle_2_solved = false

func _ready():
	_a_Stairway_2.teleported.connect(_on_Stairway_2_teleported)
	_a_Pressure_Plate_1.pushed.connect(_on_Pressure_Plate_pushed.bind(_a_Power_Cable_1))
	_a_Pressure_Plate_1.released.connect(_on_Pressure_Plate_released.bind(_a_Power_Cable_1))
	_a_Pressure_Plate_2.pushed.connect(_on_Pressure_Plate_pushed.bind(_a_Power_Cable_2))
	_a_Pressure_Plate_2.released.connect(_on_Pressure_Plate_released.bind(_a_Power_Cable_2))
	_a_Pressure_Plate_3.pushed.connect(_on_Pressure_Plate_pushed.bind(_a_Power_Cable_3))
	_a_Pressure_Plate_3.released.connect(_on_Pressure_Plate_released.bind(_a_Power_Cable_3))
	_a_Power_Cable_1.started.connect(_on_Power_Cable_started.bind(_a_Power_Cable_1, _a_Gate_1))
	_a_Power_Cable_1.completed.connect(_on_Power_Cable_completed.bind(_a_Power_Cable_1, _a_Gate_1))
	_a_Power_Cable_2.started.connect(_on_Power_Cable_started.bind(_a_Power_Cable_2, _a_Gate_2))
	_a_Power_Cable_2.completed.connect(_on_Power_Cable_completed.bind(_a_Power_Cable_2, _a_Gate_2))
	_a_Power_Cable_3.started.connect(_on_Power_Cable_started.bind(_a_Power_Cable_3, _a_Gate_3))
	_a_Power_Cable_3.completed.connect(_on_Power_Cable_completed.bind(_a_Power_Cable_3, _a_Gate_3))
	_a_Gate_1.opened.connect(_on_Gate_1_opened)
	_a_Gate_3.opened.connect(_on_Gate_3_opened)

func set_paint_delere_paint_from_projector(p_paint_from_projector, p_paint_delere):
	p_paint_delere.set_paint_from_projector(p_paint_from_projector, _a_Projector_1)

func get_save_data():
	var data = {}
	data["Puzzle_1_Solved"] = _a_puzzle_1_solved
	data["Puzzle_2_Solved"] = _a_puzzle_2_solved
	
	return data

func load_data(p_data):
	_a_puzzle_1_solved = p_data["Puzzle_1_Solved"]
	_a_puzzle_2_solved = p_data["Puzzle_2_Solved"]

func _on_Stairway_2_teleported():
	if !_a_puzzle_1_solved:
		_a_Canvas_1.set_position(Vector3(50.5, 0.0, 17.0))
		_a_Canvas_1.set_rotation_degrees(Vector3(0.0, 0.0, 0.0))
	
	if !_a_puzzle_2_solved:
		_a_Canvas_2.set_position(Vector3(44.5, 0.0, 17.5))
		_a_Canvas_2.set_rotation_degrees(Vector3(0.0, 0.0, 0.0))

func _on_Pressure_Plate_pushed(p_power_cable):
	p_power_cable.set_power(true)

func _on_Pressure_Plate_released(p_power_cable):
	p_power_cable.set_power(false)

func _on_Power_Cable_started(p_power_cable, p_gate):
	var power = p_power_cable.get_power()
	if !power:
		p_gate.comph().call_comp("States", "set_state", ["Close"])
		p_gate.comph().call_comp("Anims", "update_anim")

func _on_Power_Cable_completed(p_power_cable, p_gate):
	var power = p_power_cable.get_power()
	if power:
		p_gate.comph().call_comp("States", "set_state", ["Open"])
		p_gate.comph().call_comp("Anims", "update_anim")

func _on_Gate_1_opened():
	if !_a_Pressure_Plate_1.has_instance(_a_Canvas_1):
		return
	
	_a_Pressure_Plate_1.set_locked(true)
	_a_Canvas_1.set_freeze_enabled(true)
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Puzzle_1", "Solved")
	_a_puzzle_1_solved = true

func _on_Gate_3_opened():
	if !_a_Pressure_Plate_3.has_instance(_a_Canvas_2):
		return
	
	_a_Pressure_Plate_2.set_locked(true)
	_a_Pressure_Plate_3.set_locked(true)
	_a_Canvas_2.set_freeze_enabled(true)
	_a_Projector_1.activate_model_ray(false)
	_a_puzzle_2_solved = true
