extends Control
class_name MiniGameRightOnTheNutQTBar

signal stopped(p_on_target: bool)

@export var _e_target_min_size_x: int = 50
@export var _e_target_max_size_x: int = 200

@onready var _a_Target: ColorRect = get_node("Target")
@onready var _a_Arrow: TextureRect = get_node("Arrow")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")
@onready var _a_Audio_Hit: AudioStreamPlayer = get_node("Audio/Hit")
@onready var _a_Audio_Miss: AudioStreamPlayer = get_node("Audio/Miss")

var _a_target_min_pos_x: int = 9
var _a_target_max_pos_x: int = -1

func _ready() -> void:
	set_process_unhandled_input(false)
	hide()

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"OK"):
		var on_target: bool = _is_arrow_on_target()
		if on_target:
			_a_Audio_Hit.play()
		else:
			_a_Audio_Miss.play()
		stopped.emit(on_target)

func open(p_diff: int, p_preview: bool) -> void:
	update_target(p_diff)
	_a_Anims.play(&"Move_Arrow")
	_a_Anims.seek(0.5, false, true)
	update_custom_speed(p_diff)
	
	set_process_unhandled_input(!p_preview)
	show()

func close() -> void:
	_a_Anims.play(&"RESET")
	
	set_process_unhandled_input(false)
	hide()

func update_target(p_diff: int) -> void:
	# 0 <= p_diff <= 9
	var size_x_diff: int = _e_target_max_size_x - _e_target_min_size_x
	var size_x: int = _e_target_max_size_x
	var rndm: float = randf() / 10.0 + (10 - p_diff) / 10.0
	size_x -= int(size_x_diff * (1.0 - rndm))
	_a_target_max_pos_x = 567 - size_x
	
	var pos_x: int = randi() % (_a_target_max_pos_x + 1) + _a_target_min_pos_x
	_a_Target.position.x = pos_x
	_a_Target.size.x = size_x

func update_custom_speed(p_diff: int) -> void:
	var custom_speed: float = 1.0 + p_diff / 10.0
	_a_Anims.set_speed_scale(custom_speed)

func _is_arrow_on_target() -> bool:
	var arrow_size: Vector2 = _a_Arrow.get_size()
	var arrow_center_pos: Vector2 = _a_Arrow.get_position() + arrow_size / 2.0
	var target_size: Vector2 = _a_Target.get_size()
	var target_pos: Vector2 = _a_Target.get_position()
	
	if arrow_center_pos.x + 3 > target_pos.x:
		if arrow_center_pos.x - 3 < target_pos.x + target_size.x:
			return true
	
	return false
