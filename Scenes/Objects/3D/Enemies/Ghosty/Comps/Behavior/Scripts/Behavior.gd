extends ObjectEnemyCompBehaviorBase
class_name ObjectEnemyGhostyCompBehavior

@export var _e_visibility_CD_min: float = 3.0
@export var _e_visibility_CD_max: float = 10.0

@onready var _a_Invisible_CD: Timer = get_node("Invisible_CD")

var _a_check_vision: bool = false

func _ready() -> void:
	_a_Invisible_CD.timeout.connect(_on_Invisible_CD_timeout)
	
	_start_invisible_CD()

func _process(p_delta: float) -> void:
	super(p_delta)
	
	if _a_check_vision:
		var can_see: bool = _a_target.comph().call_comp("Vision", &"can_see_instance", [_a_entity])
		if can_see:
			_set_state(&"Look_At")
		else:
			if _a_state != &"Chase":
				_set_state(&"Chase")

func _start_invisible_CD() -> void:
	var invisible_CD: float = randf_range(_e_visibility_CD_min, _e_visibility_CD_max)
	_a_Invisible_CD.start(invisible_CD)

func _set_state(p_state: StringName, p_process: bool = true) -> void:
	super(p_state, p_process)
	match p_state:
		&"In_Battle":
			_a_Target_Range.set_monitoring(false)
			_a_check_vision = false
		&"Respawn":
			_a_Target_Range.set_monitoring(false)
			_a_check_vision = false
		_:
			_a_Target_Range.set_monitoring(true)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Check_Vision"] = _a_check_vision
	
	return data

func load_data(p_data: Dictionary) -> void:
	await _a_entity_comph.comps_registered
	super(p_data)
	if p_data[&"Check_Vision"]:
		_a_target.comph().call_comp("Vision", &"disable")

func load_data_init() -> void:
	await _a_entity_comph.comps_registered
	
	_set_state(&"Rndm")

func _on_Target_Range_body_entered(_p_body) -> void:
	_a_check_vision = true
	_a_target.comph().call_comp("Vision", &"enable")

func _on_Target_Range_body_exited(_p_body) -> void:
	_a_check_vision = false
	_a_target.comph().call_comp("Vision", &"disable")
	_set_queued_state(&"Rndm")

func _on_Invisible_CD_timeout() -> void:
	var display_comp: CompDisplay3D = _a_entity_comph.get_comp("Display")
	var rndm: int = randi() % 2
	var a: float = 0.0
	if rndm == 1:
		a = randf_range(0.0, 0.4)
	var tween: Tween = create_tween()
	tween.finished.connect(_on_Tween_finished)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(display_comp, "modulate:a", a, 4.0)
	
	var visible_CD: float = randf_range(_e_visibility_CD_min, _e_visibility_CD_max)
	if rndm == 0:
		visible_CD /= 2.0
	tween.tween_property(display_comp, "modulate:a", 1.0, 4.0).set_delay(visible_CD)

func _on_Tween_finished() -> void:
	_start_invisible_CD()
