extends Node
class_name CompMovementControllerBase

@onready var _a_Idle_CD: Timer = get_node("Idle_CD")

var _a_entity: Node
var _a_entity_comph: CompHandler
var _a_movement: Node
var _a_movement_comph: CompHandler

var _a_velocity: Variant # Vector
var _a_can_jump: bool = true

func _ready() -> void:
	_a_Idle_CD.timeout.connect(_on_Idle_CD_timeout)
	
	set_process_unhandled_input(_a_can_jump)

func _process(_p_delta: float) -> void: 
	_check_idle()

func _physics_process(_p_delta: float) -> void:
	_process_move()
	_a_entity_comph.call_comp("Anims", &"update_anim")

func _unhandled_input(p_event: InputEvent) -> void:
	if _a_entity.is_on_floor():
		if p_event.is_action_pressed("Jump"):
			_a_movement_comph.call_comp("Jump", &"jump")

func init(p_entity: Node) -> void:
	_a_entity = p_entity
	_a_entity_comph = _a_entity.comph()
	_a_movement = _a_entity_comph.get_comp("Movement")
	_a_movement_comph = _a_movement.comph()
	
	if _a_entity_comph.has_comp("Operate"):
		var operate_comp: CompOperate = _a_entity_comph.get_comp("Operate")
		operate_comp.to_disabled.connect(_on_Operate_to_disabled)
		operate_comp.to_enabled.connect(_on_Operate_to_enabled)

func _process_move() -> void:
	_a_velocity = _get_input_velocity()
	_a_velocity = _a_velocity.normalized()
	
	if _a_velocity.length() > 0.0:
		var dir: StringName = Global.get_vec_dir(_a_velocity)
		_a_movement.set_dir(dir)
	
	_change_state(_a_velocity)
	_a_velocity *= _a_movement.get_speed()

func _change_state(p_velocity: Variant) -> void:
	if p_velocity.length() > 0.0:
		if Input.is_action_pressed(&"Move_Run"):
			_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Run"])
		else:
			_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Walk"])
	else:
		var state_tmp: StringName = _a_entity_comph.call_comp("States", &"get_state_tmp")
		if state_tmp != &"Idle":
			_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Stop"])

func _check_idle() -> void:
	var state_tmp: StringName = _a_entity_comph.call_comp("States", &"get_state_tmp")
	if state_tmp == &"Stop":
		if _a_Idle_CD.is_stopped():
			_a_Idle_CD.start()
	else:
		_a_Idle_CD.stop()

func set_can_jump(p_can_jump: bool) -> void:
	_a_can_jump = p_can_jump
	set_process_unhandled_input(p_can_jump)

func reset_velocity() -> void:
	_a_velocity = _a_movement.get_init_velocity()

func adjust_velocity_post(p_velocity: Variant) -> Variant:
	return p_velocity

func get_velocity_() -> Variant:
	return _a_velocity

func get_speed() -> float:
	return 0.0

func _get_input_velocity() -> Variant:
	return null

func _is_on_floor() -> bool:
	return false

func _on_Operate_to_disabled() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	reset_velocity()
	_a_Idle_CD.stop()
	_a_movement.stop()

func _on_Operate_to_enabled() -> void:
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(_a_can_jump)
	_check_idle()

func _on_Idle_CD_timeout() -> void:
	_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Idle"])
