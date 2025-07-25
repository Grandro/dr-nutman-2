extends Control

signal stopped(p_on_target)

@export var _e_target_min_size_x: int = 50
@export var _e_target_max_size_x: int = 200

@onready var _a_Target = get_node("Target")
@onready var _a_Arrow = get_node("Arrow")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Audio_Hit = get_node("Audio/Hit")
@onready var _a_Audio_Miss = get_node("Audio/Miss")

var _a_target_min_pos_x = 9
var _a_target_max_pos_x = -1

func _ready():
	set_process_unhandled_input(false)
	hide()

func _unhandled_input(p_event):
	if p_event.is_action_pressed("OK"):
		var on_target = _is_arrow_on_target()
		if on_target:
			_a_Audio_Hit.play()
		else:
			_a_Audio_Miss.play()
		stopped.emit(on_target)

func open(p_diff, p_preview):
	update_target(p_diff)
	_a_Anims.play("Move_Arrow")
	_a_Anims.seek(0.5, false, true)
	update_custom_speed(p_diff)
	
	set_process_unhandled_input(!p_preview)
	show()

func close():
	_a_Anims.play("RESET")
	
	set_process_unhandled_input(false)
	hide()

func update_target(p_diff):
	# 0 <= p_diff <= 9
	var size_x_dif = _e_target_max_size_x - _e_target_min_size_x
	var size_x = _e_target_max_size_x
	var rndm = randf() / 10.0 + (10 - p_diff) / 10.0
	size_x -= int(size_x_dif * (1.0 - rndm))
	_a_target_max_pos_x = 567 - size_x
	
	var pos_x = randi() % (_a_target_max_pos_x + 1) + _a_target_min_pos_x
	_a_Target.position.x = pos_x
	_a_Target.size.x = size_x

func update_custom_speed(p_diff):
	var custom_speed = 1.0 + p_diff / 10.0
	_a_Anims.set_speed_scale(custom_speed)

func _is_arrow_on_target():
	var arrow_size = _a_Arrow.get_size()
	var arrow_center_pos = _a_Arrow.get_position() + arrow_size / 2
	var target_size = _a_Target.get_size()
	var target_pos = _a_Target.get_position()
	
	var on_target = false
	if arrow_center_pos.x + 3 > target_pos.x:
		if arrow_center_pos.x - 3 < target_pos.x + target_size.x:
			on_target = true
	
	return on_target
