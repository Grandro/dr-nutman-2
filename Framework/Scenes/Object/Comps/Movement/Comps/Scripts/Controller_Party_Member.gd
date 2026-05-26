extends FWCompMovementControllerBase
class_name FWCompMovementControllerPartyMember

@onready var _a_Idle_CD: Timer = get_node("Idle_CD")

var _a_can_jump: bool = true

func _ready() -> void:
	super()
	_a_Idle_CD.timeout.connect(_on_Idle_CD_timeout)
	
	set_process_unhandled_input(_a_can_jump)

func _process(_p_delta: float) -> void: 
	_check_idle()

func _physics_process(p_delta: float) -> void:
	super(p_delta)
	_a_entity_comph.call_comp("Anims", &"update_anim")

func _unhandled_input(p_event: InputEvent) -> void:
	if _a_entity.is_on_floor():
		if p_event.is_action_pressed("Jump"):
			_a_movement_comph.call_comp("Jump", &"jump")

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

func _on_Operate_to_disabled() -> void:
	super()
	set_process(false)
	set_process_unhandled_input(false)
	_a_Idle_CD.stop()

func _on_Operate_to_enabled() -> void:
	super()
	set_process(true)
	set_process_unhandled_input(_a_can_jump)
	_check_idle()

func _on_Idle_CD_timeout() -> void:
	_a_entity_comph.call_comp("States", &"set_state_tmp", [&"Idle"])
