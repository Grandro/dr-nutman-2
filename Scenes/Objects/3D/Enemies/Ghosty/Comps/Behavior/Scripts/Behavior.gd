extends "res://Scenes/Objects/3D/Enemies/Comps/Behavior/Scripts/Behavior_Base.gd"

@export var _e_visibility_CD_min : float = 3.0
@export var _e_visibility_CD_max : float = 10.0

@onready var _a_Invisible_CD = get_node("Invisible_CD")

var _a_check_vision = false

func _ready():
	_a_Invisible_CD.timeout.connect(_on_Invisible_CD_timeout)
	
	_start_invisible_CD()

func _process(p_delta):
	super(p_delta)
	
	if _a_check_vision:
		var can_see = _a_target.comph().call_comp("Vision", "can_see_instance", [_a_entity])
		if can_see:
			_set_state("Look_At")
		else:
			if _a_state != "Chase":
				_set_state("Chase")

func _start_invisible_CD():
	var invisible_CD = randf_range(_e_visibility_CD_min, _e_visibility_CD_max)
	_a_Invisible_CD.start(invisible_CD)

func _set_state(p_state, p_process = true):
	super(p_state, p_process)
	match p_state:
		"In_Battle":
			_a_Target_Range.set_monitoring(false)
			_a_check_vision = false
		"Respawn":
			_a_Target_Range.set_monitoring(false)
			_a_check_vision = false
		_:
			_a_Target_Range.set_monitoring(true)

func get_save_data():
	var data = super()
	data["Check_Vision"] = _a_check_vision
	
	return data

func load_data(p_data):
	await _a_entity_comph.comps_registered
	super(p_data)
	if p_data["Check_Vision"]:
		_a_target.comph().call_comp("Vision", "disable")

func load_data_init():
	await _a_entity_comph.comps_registered
	
	_set_state("Rndm")

func _on_Target_Range_body_entered(_p_body):
	_a_check_vision = true
	_a_target.comph().call_comp("Vision", "enable")

func _on_Target_Range_body_exited(_p_body):
	_a_check_vision = false
	_a_target.comph().call_comp("Vision", "disable")
	_set_queued_state("Rndm")

func _on_Invisible_CD_timeout():
	var display_comp = _a_entity_comph.get_comp("Display")
	var rndm = randi() % 2
	var a = 0.0
	if rndm == 1:
		a = randf_range(0.0, 0.4)
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(display_comp, "modulate:a", a, 4.0)
	
	var visible_CD = randf_range(_e_visibility_CD_min, _e_visibility_CD_max)
	if rndm == 0:
		visible_CD /= 2.0
	
	tween.tween_property(display_comp, "modulate:a", 1.0, 4.0).set_delay(visible_CD)

func _on_Tween_finished():
	_start_invisible_CD()
