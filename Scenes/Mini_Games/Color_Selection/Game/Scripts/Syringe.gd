extends Node2D

signal request_paint_drop(p_pos)
signal completed_spurt_sequence()

const _a_DEFAULT_POS = Vector2(637, -90)
const _a_MIN_X_POS = 541
const _a_MAX_X_POS = 733
const _a_END_Y_POS = 112

@export var _e_drops_per_spurt: int = 20

@onready var _a_Sprite_Red = get_node("Sprites/Red")
@onready var _a_Sprite_Green = get_node("Sprites/Green")
@onready var _a_Sprite_Blue = get_node("Sprites/Blue")
@onready var _a_Paint_Drop_Timer = get_node("Paint_Drop_Timer")
@onready var _a_Move_Up_Timer = get_node("Move_Up_Timer")

var _a_tweens = []
var _a_sprite = null # Current sprite instance
var _a_color = null # Current color
var _a_state = "Idle" # Idle / Move_Down / Move_Up / Spurt
var _a_drop_count = 0 # Drop count of current spurt sequence

func _ready():
	_a_Paint_Drop_Timer.timeout.connect(_on_Paint_Drop_Timer_timeout)
	_a_Move_Up_Timer.timeout.connect(_on_Move_Up_Timer_timeout)
	
	_a_Sprite_Red.hide()
	_a_Sprite_Green.hide()
	_a_Sprite_Blue.hide()

func move_down(p_color):
	_a_state = "Move_Down"
	set_position(_a_DEFAULT_POS)
	_change_color(p_color)
	
	randomize()
	var to_pos = Vector2(0, _a_END_Y_POS)
	var x_span = _a_MAX_X_POS - _a_MIN_X_POS
	to_pos.x = _a_MIN_X_POS + randi() % (x_span + 1)
	set_position(Vector2(to_pos.x, _a_DEFAULT_POS.y))
	
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished.bind(tween))
	tween.tween_property(self, "position", to_pos, 2)
	_a_tweens.push_back(tween)

func _move_up():
	_a_state = "Move_Up"
	
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished.bind(tween))
	tween.tween_property(self, "position:y", _a_DEFAULT_POS.y, 2)
	_a_tweens.push_back(tween)

func _spurt_sequence():
	_a_state = "Spurt"
	
	_move_to_x_pos()
	_a_Paint_Drop_Timer.start()

func _move_to_x_pos():
	var x_span = _a_MAX_X_POS - _a_MIN_X_POS
	var x_to_pos = float(_a_MIN_X_POS + randi() % (x_span + 1))
	var distance = abs(position.x - x_to_pos)
	var duration = distance / 120
	
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished.bind(tween))
	tween.tween_property(self, "position:x", x_to_pos, duration)
	_a_tweens.push_back(tween)

func _change_color(p_color):
	if _a_sprite != null:
		_a_sprite.hide()
	
	match p_color:
		Color.RED: _a_sprite = _a_Sprite_Red
		Color.GREEN: _a_sprite = _a_Sprite_Green
		Color.BLUE: _a_sprite = _a_Sprite_Blue
	_a_sprite.show()
	
	_a_color = p_color

func _on_Tween_finished(p_tween):
	match _a_state:
		"Move_Down":
			# Moving down finished -> Start spurt sequence
			_spurt_sequence()
		"Move_Up":
			# Moving up finished -> End spurt sequence after delay
			_a_state = "Idle"
			_a_Move_Up_Timer.start()
		"Spurt":
			_move_to_x_pos()
	
	_a_tweens.erase(p_tween)

func _on_Paint_Drop_Timer_timeout():
	var pos = position + Vector2(1, 100)
	request_paint_drop.emit(pos)
	
	_a_drop_count += 1
	if _a_drop_count == _e_drops_per_spurt:
		_a_drop_count = 0
		_a_Paint_Drop_Timer.stop()
		for tween in _a_tweens:
			tween.kill()
		_a_tweens.clear()
		_move_up()

func _on_Move_Up_Timer_timeout():
	completed_spurt_sequence.emit()
