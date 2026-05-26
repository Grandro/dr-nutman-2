@tool
extends FWPlaneTile
class_name PowerCableStripe

signal completed()

var _a_area_per_s: float = 0.0
var _a_total_area: float = 0.0
var _a_area: float = 0.0 # 0.0 <= _a_area <= total_area
var _a_power: bool = false
var _a_tween: Tween = null

func _ready() -> void:
	var size: Vector2 = mesh.get_size()
	_a_total_area = size.x * size.y

func set_area_per_s(p_area_per_s: float) -> void:
	_a_area_per_s = p_area_per_s

func set_power(p_power: bool) -> void:
	_a_power = p_power
	
	var remaining_area: float = _a_area
	var to_area: float = 0.0
	if p_power:
		remaining_area = _a_total_area - _a_area
		to_area = _a_total_area
	if remaining_area == 0.0:
		return
	var duration: float = remaining_area / _a_area_per_s
	
	if _a_tween != null:
		_a_tween.kill()
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Tween_finished)
	_a_tween.tween_method(set_area, _a_area, to_area, duration)

func set_area(p_area: float) -> void:
	_a_area = p_area
	
	var progress: float = p_area / _a_total_area
	var next_pass: Material = mesh.material.next_pass
	next_pass.set(&"shader_parameter/progress", progress)

func set_completed(p_power: bool) -> void:
	_a_power = p_power
	if _a_tween != null:
		_a_tween.kill()
	if p_power:
		set_area(_a_total_area)
	else:
		set_area(0.0)
	
	completed.emit()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Area"] = _a_area
	data[&"Power"] = _a_power
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_area(p_data[&"Area"])
	set_power(p_data[&"Power"])

func _on_Tween_finished() -> void:
	completed.emit()
