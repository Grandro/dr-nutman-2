@tool
extends "res://Global_Resources/Mapping/3D/Plane/Scripts/Plane_Tile.gd"

signal completed()

var _a_area_per_s = 0.0
var _a_total_area = 0.0
var _a_area = 0.0 # 0.0 <= _a_area <= total_area
var _a_power = false
var _a_tween = null

func _ready():
	var size = mesh.get_size()
	_a_total_area = size.x * size.y

func set_area_per_s(p_area_per_s):
	_a_area_per_s = p_area_per_s

func set_power(p_power):
	_a_power = p_power
	
	var remaining_area = _a_area
	var to_area = 0.0
	if p_power:
		remaining_area = _a_total_area - _a_area
		to_area = _a_total_area
	if is_equal_approx(remaining_area, 0.0):
		return
	var duration = remaining_area / _a_area_per_s
	
	if _a_tween != null:
		_a_tween.kill()
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Tween_finished)
	_a_tween.tween_method(set_area, _a_area, to_area, duration)

func set_area(p_area):
	_a_area = p_area
	
	var progress = p_area / _a_total_area
	var next_pass = mesh.material.next_pass
	next_pass.set("shader_parameter/progress", progress)

func get_save_data():
	var data = {}
	data["Area"] = _a_area
	data["Power"] = _a_power
	
	return data

func load_data(p_data):
	set_area(p_data["Area"])
	set_power(p_data["Power"])

func _on_Tween_finished():
	completed.emit()
