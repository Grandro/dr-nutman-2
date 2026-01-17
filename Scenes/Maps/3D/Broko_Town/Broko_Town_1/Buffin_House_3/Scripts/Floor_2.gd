extends Node3D
class_name MapBuffinHouse3Floor2

signal projector_power_changed(p_projector: ObjectProjectorBase, p_power: bool)

@onready var _a_Pressure_Plate_4: ObjectPressurePlateBase = get_node("Pressure_Plate_4")
@onready var _a_Pressure_Plate_5: ObjectPressurePlateBase = get_node("Pressure_Plate_5")
@onready var _a_Power_Cable_4: PowerCable = get_node("Power_Cable_4")
@onready var _a_Power_Cable_5: PowerCable = get_node("Power_Cable_5")
@onready var _a_Power_Cable_6: PowerCable = get_node("Power_Cable_6")
@onready var _a_Rails: Node3D = get_node("Rails")
@onready var _a_Rails_1: Rails = get_node("Rails/Rails_1")
@onready var _a_Rails_2: Rails = get_node("Rails/Rails_2")
@onready var _a_Gate_4: ObjectGate1 = get_node("Gate_4")
@onready var _a_Gate_5: ObjectGate1 = get_node("Gate_5")

var _a_paint_delere: MapBuffinHouse3ObjectPaintDeLere
var _a_puzzle_3_solved: bool = false
var _a_puzzle_4_solved: bool = false

func _ready() -> void:
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
	
	for child: Rails in _a_Rails.get_children():
		var rail_cars: Array[Node] = child.get_rail_cars()
		for rail_car: RailCarBase in rail_cars:
			if !rail_car.has_signal(&"projector_power_changed"):
				continue
			rail_car.projector_power_changed.connect(_on_Rail_Car_projector_power_changed.bind(child))

func set_paint_delere(p_paint_delere: MapBuffinHouse3ObjectPaintDeLere) -> void:
	_a_paint_delere = p_paint_delere

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Puzzle_3_Solved"] = _a_puzzle_3_solved
	data[&"Puzzle_4_Solved"] = _a_puzzle_4_solved
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_puzzle_3_solved = p_data[&"Puzzle_3_Solved"]
	_a_puzzle_4_solved = p_data[&"Puzzle_4_Solved"]

func _on_Pressure_Plate_pushed(p_power_cable: PowerCable) -> void:
	p_power_cable.set_power(true)

func _on_Pressure_Plate_released(p_power_cable: PowerCable) -> void:
	p_power_cable.set_power(false)

func _on_Power_Cable_started(p_power_cable: PowerCable, p_gate: ObjectGate1) -> void:
	var power: bool = p_power_cable.get_power()
	if !power:
		p_gate.comph().call_comp("States", &"set_state", [&"Close"])
		p_gate.comph().call_comp("Anims", &"update_anim")

func _on_Power_Cable_completed(p_power_cable: PowerCable, p_gate: ObjectGate1) -> void:
	var power: bool = p_power_cable.get_power()
	if power:
		p_gate.comph().call_comp("States", &"set_state", [&"Open"])
		p_gate.comph().call_comp("Anims", &"update_anim")

func _on_Gate_4_opened() -> void:
	if !_a_Pressure_Plate_4.has_instance(_a_paint_delere):
		return
	_a_Pressure_Plate_4.set_locked(true)
	_a_puzzle_3_solved = true
	
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Puzzle_3", &"Solved")

func _on_Gate_5_opened() -> void:
	if !_a_Pressure_Plate_5.has_instance(_a_paint_delere):
		return
	_a_Pressure_Plate_5.set_locked(true)
	_a_puzzle_4_solved = true
	
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Puzzle_4", &"Solved")

func _on_Rail_Car_projector_power_changed(p_projector: ObjectProjectorBase, p_power: bool, p_rails: Rails) -> void:
	match p_rails:
		_a_Rails_1:
			if !_a_puzzle_3_solved:
				projector_power_changed.emit(p_projector, p_power)
		_a_Rails_2:
			if !_a_puzzle_4_solved:
				projector_power_changed.emit(p_projector, p_power)
