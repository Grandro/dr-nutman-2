extends Node
class_name CompMovementJumpBase

signal jumped()

@export var _e_speed: float = 15.0

var _a_entity: Node
var _a_entity_comph: CompHandler
var _a_movement: Node

var _a_gravity_vec: Variant # Vector
var _a_gravity: float
var _a_velocity: Variant # Vector
var _a_init: bool = false # Jump has been initialized, can still be on floor
var _a_active: bool = false # Is in air while jumping

func _physics_process(p_delta: float) -> void:
	_process_gravity(p_delta)
	
	if _a_init && !_a_entity.is_on_floor():
		_a_active = true
		_a_init = false
	if _a_active && _a_entity.is_on_floor():
		_a_active = false
		jumped.emit()

func init(p_entity: Node) -> void:
	_a_entity = p_entity
	_a_entity_comph = _a_entity.comph()
	_a_movement = _a_entity_comph.get_comp("Movement")
	
	var anims_comp: CompAnims = _a_entity_comph.get_comp("Anims")
	anims_comp.animation_finished.connect(_on_Anims_anim_finished)

func jump(p_speed: float = _e_speed) -> void:
	_a_init = true
	_a_velocity.y += p_speed
	
	_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Jump"])
	_a_entity_comph.call_comp("Anims", &"update_anim")
	_a_entity_comph.call_comp("Audio", &"play", [&"Jump"])

func _process_gravity(p_delta: float) -> void:
	if !_a_entity.is_on_floor():
		_a_velocity += _a_gravity_vec * _a_gravity * p_delta * 4
	else:
		reset_velocity()

func reset_velocity() -> void:
	_a_velocity = _a_movement.get_init_velocity()

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	return p_velocity

func get_velocity_() -> Variant:
	return _a_velocity

func get_speed() -> float:
	return 0.0

func _on_Anims_anim_finished(p_name: StringName) -> void:
	if "Jump" in p_name:
		_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Fall"])
		_a_entity_comph.call_comp("Anims", &"update_anim")
