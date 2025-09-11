extends Node3D

signal projector_power_changed(p_projector, p_power)

@onready var _a_Pressure_Plate_4 = get_node("Pressure_Plate_4")
@onready var _a_Pressure_Plate_5 = get_node("Pressure_Plate_5")
@onready var _a_Power_Cable_4 = get_node("Power_Cable_4")
@onready var _a_Power_Cable_5 = get_node("Power_Cable_5")
@onready var _a_Power_Cable_6 = get_node("Power_Cable_6")
@onready var _a_Rails = get_node("Rails")
@onready var _a_Rails_1 = get_node("Rails/Rails_1")
@onready var _a_Rails_2 = get_node("Rails/Rails_2")
@onready var _a_Gate_4 = get_node("Gate_4")
@onready var _a_Gate_5 = get_node("Gate_5")

var _a_paint_delere = null
var _a_puzzle_3_solved = false
var _a_puzzle_4_solved = false

func _ready():
	_a_Pressure_Plate_4.pushed.connect(_on_Pressure_Plate_pushed.bind(_a_Power_Cable_4))
	_a_Pressure_Plate_4.released.connect(_on_Pressure_Plate_released.bind(_a_Power_Cable_4))
	_a_Pressure_Plate_5.pushed.connect(_on_Pressure_Plate_pushed.bind(_a_Power_Cable_6))
	_a_Pressure_Plate_5.released.connect(_on_Pressure_Plate_released.bind(_a_Power_Cable_6))
	_a_Power_Cable_4.started.connect(_on_Power_Cable_started.bind(_a_Power_Cable_4, _a_Gate_4))
	_a_Power_Cable_4.completed.connect(_on_Power_Cable_completed.bind(_a_Power_Cable_4, _a_Gate_4))
	_a_Power_Cable_6.started.connect(_on_Power_Cable_started.bind(_a_Power_Cable_6, _a_Gate_5))
	_a_Power_Cable_6.completed.connect(_on_Power_Cable_completed.bind(_a_Power_Cable_6, _a_Gate_5))
	_a_Gate_4.opened.connect(_on_Gate_4_opened)
	_a_Gate_5.opened.connect(_on_Gate_5_opened)
	
	_a_Power_Cable_5.set_completed(true)
	
	for rails in _a_Rails.get_children():
		var rail_cars = rails.get_rail_cars()
		for rail_car in rail_cars:
			if !rail_car.has_signal("projector_power_changed"):
				continue
			rail_car.projector_power_changed.connect(_on_Rail_Car_projector_power_changed.bind(rails))

func set_paint_delere(p_paint_delere):
	_a_paint_delere = p_paint_delere

func get_save_data():
	var data = {}
	data["Puzzle_3_Solved"] = _a_puzzle_3_solved
	data["Puzzle_4_Solved"] = _a_puzzle_4_solved
	
	return data

func load_data(p_data):
	_a_puzzle_3_solved = p_data["Puzzle_3_Solved"]
	_a_puzzle_4_solved = p_data["Puzzle_4_Solved"]

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

func _on_Gate_4_opened():
	if !_a_Pressure_Plate_4.has_instance(_a_paint_delere):
		return
	_a_Pressure_Plate_4.set_locked(true)
	_a_puzzle_3_solved = true
	
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Puzzle_3", "Solved")

func _on_Gate_5_opened():
	if !_a_Pressure_Plate_5.has_instance(_a_paint_delere):
		return
	_a_Pressure_Plate_5.set_locked(true)
	_a_puzzle_4_solved = true
	
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Puzzle_4", "Solved")

func _on_Rail_Car_projector_power_changed(p_projector, p_power, p_rails):
	match p_rails:
		_a_Rails_1:
			if !_a_puzzle_3_solved:
				projector_power_changed.emit(p_projector, p_power)
		_a_Rails_2:
			if !_a_puzzle_4_solved:
				projector_power_changed.emit(p_projector, p_power)
