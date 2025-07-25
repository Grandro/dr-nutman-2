extends Node3DObject

signal started()
signal completed()

@export var _e_area_per_s : float = 1.0
@export var _e_simul: bool = false

@onready var _a_Parts = get_node("Parts")

var _a_part = null # Current part instance
var _a_power = false
var _a_from_start = true
var _a_finish_count = 0

func _ready():
	super()
	if !_a_comph.has_comp("Save"):
		load_data_init()

func _init_parts():
	for child in _a_Parts.get_children():
		if _e_simul:
			child.completed.connect(_on_Part_completed)
		child.set_area_per_s(_e_area_per_s)

func _change_part(p_idx):
	if _a_part != null:
		_a_part.completed.disconnect(_on_Part_completed)
	_a_part = _a_Parts.get_child(p_idx)
	_a_part.completed.connect(_on_Part_completed)

func set_area_per_s(p_area_per_s):
	_e_area_per_s = p_area_per_s
	for child in _a_Parts.get_children():
		child.set_area_per_s(p_area_per_s)

func set_power(p_power):
	_a_power = p_power
	
	if _e_simul:
		for child in _a_Parts.get_children():
			child.set_power(p_power)
	else:
		_a_part.set_power(p_power)
	
	if _a_from_start:
		_a_from_start = false
		started.emit()

func get_power():
	return _a_power

func get_save_data():
	var data = super()
	data["Parts"] = []
	for child in _a_Parts.get_children():
		var child_data = child.get_save_data()
		data["Parts"].push_back(child_data)
	data["Area_Per_S"] = _e_area_per_s
	data["Simul"] = _e_simul
	data["Part_Idx"] = _a_part.get_index()
	data["Power"] = _a_power
	data["From_Start"] = _a_from_start
	data["Finish_Count"] = _a_finish_count
	
	return data

func load_data(p_data):
	super(p_data)
	_e_area_per_s = p_data["Area_Per_S"]
	_e_simul = p_data["Simul"]
	_a_power = p_data["Power"]
	_a_from_start = p_data["From_Start"]
	_a_finish_count = p_data["Finish_Count"]
	
	_init_parts()
	for i in _a_Parts.get_child_count():
		var child = _a_Parts.get_child(i)
		child.load_data(p_data["Parts"][i])
	
	if !_e_simul:
		_change_part(p_data["Part_Idx"])

func load_data_init():
	_init_parts()
	if !_e_simul:
		_change_part(0)

func _on_Part_completed():
	if _e_simul:
		_a_finish_count += 1
		if _a_finish_count == _a_Parts.get_child_count():
			_a_from_start = true
			_a_finish_count = 0
			completed.emit()
		return
	
	var idx = _a_part.get_index()
	if _a_power:
		if idx == _a_Parts.get_child_count() - 1:
			_a_from_start = true
			completed.emit()
			return
		_change_part(idx + 1)
	else:
		if idx == 0:
			_a_from_start = true
			completed.emit()
			return
		_change_part(idx - 1)
	
	_a_part.set_power(_a_power)
