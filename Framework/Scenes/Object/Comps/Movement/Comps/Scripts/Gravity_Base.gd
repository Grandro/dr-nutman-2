extends Node
class_name FWCompMovementGravityBase

var _a_entity: Node
var _a_movement: Node

var _a_velocity: Variant # Vector
var _a_gravity_vec: Variant # Vector
var _a_gravity: float

func _physics_process(p_delta: float) -> void:
	if _a_entity.is_on_floor():
		reset_velocity()
	else:
		_a_velocity += _a_gravity_vec * _a_gravity * p_delta * 4.0

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-2]
	_a_movement = p_entities[-1]

func reset_velocity() -> void:
	_a_velocity = _a_movement.get_init_velocity()

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	return p_velocity

func get_velocity_() -> Variant:
	return _a_velocity

func get_speed() -> float:
	return 0.0

func set_disabled(p_disabled: bool) -> void:
	reset_velocity()
	set_physics_process(!p_disabled)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Disabled"] = !is_physics_processing()
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_disabled(p_data[&"Disabled"])

func load_data_init() -> void:
	pass
