extends "res://Scenes/Mini_Games/Mini_Game_Base/Scripts/Game_Base.gd"

const _a_MOVE_SQUIRREL_DIRS = [-1, 1]
const _a_MOVE_SQUIRREL_FRAME_AMOUNTS = [1, 3, 6]

@export var _e_squirrels_per_round: int = 3
@export var _e_time_per_frame : float = 0.06
@export var _e_delay_min : float = 0.0
@export var _e_delay_max : float = 0.2

@onready var _a_Back_Button = get_node("Canvas_2/Margin/Back_Button")
@onready var _a_Cracked_Peanut_Amount = get_node("Canvas_2/Margin/Cracked_Peanut_Amount")
@onready var _a_Squirrel_Body = get_node("Squirrel/Body")
@onready var _a_Squirrel_Hands = get_node("Squirrel/Hands")
@onready var _a_Camera = get_node("Camera")
@onready var _a_Audio_Fun_Up = get_node("Audio/Fun_Up")
@onready var _a_Audio_Whoosh = get_node("Audio/Whoosh")
@onready var _a_Audio_Laugh = get_node("Audio/Laugh")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Delay = get_node("Delay")

var _a_curr_round = 0
var _a_curr_squirrel = 0
var _a_tween = null

func _ready():
	super()
	_a_Back_Button.select_pressed.connect(_on_Back_Button_select_pressed)
	_a_Anims.animation_finished.connect(_on_anim_finished)
	_a_Delay.timeout.connect(_on_Delay_timeout)
	
	set_process_unhandled_input(false)
	
	_a_Back_Button.hide()
	_a_Cracked_Peanut_Amount.hide()

func _unhandled_input(p_event):
	if p_event.is_action_pressed("OK"):
		_process_catch_pressed()

func open():
	_a_Camera.make_current()
	
	_set_squirrel_frame(6)
	_move_squirrel_hands()
	set_process_unhandled_input(true)
	
	super()
	_a_Back_Button.show()
	_a_Cracked_Peanut_Amount.show()

func close():
	set_process_unhandled_input(false)
	_a_curr_round = 0
	_a_curr_squirrel = 0
	_a_Back_Button.hide()
	_a_Cracked_Peanut_Amount.hide()
	super()

func _finish_round():
	_a_Back_Button.set_select_diabled(true)
	
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	var key = "Squirrel_Fishing_Round_Finish"
	cutscene_system_si.cutscene(key, "Entry", "Main", "Global")
	cutscene_system_si.set_cutscene_completed_cb(key, "Entry", _CB_cutscene_completed)

func _process_catch_pressed():
	set_process_unhandled_input(false)
	_stop_squirrel_hands()
	
	var frame = _a_Squirrel_Body.get_frame()
	if frame == 0:
		_a_Audio_Fun_Up.play()
		_a_Audio_Whoosh.play()
		_a_Anims.play("Pull_Catch")
	else:
		_a_Audio_Laugh.play()
		_a_Anims.play("Pull_Fail")

func _move_squirrel_hands():
	var dir = _get_rndm_move_squirrel_dir()
	var frame_amount = _get_rndm_move_squirrel_frame_amount(dir)
	_tween_squirrel_frame(dir, frame_amount)

func _tween_squirrel_frame(p_dir, p_frame_amount):
	var curr_frame = _a_Squirrel_Body.get_frame()
	var new_frame = curr_frame + p_dir * p_frame_amount
	var duration = _e_time_per_frame * p_frame_amount
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Tween_finished)
	_a_tween.set_trans(Tween.TRANS_LINEAR)
	_a_tween.set_parallel(true)
	_a_tween.tween_property(_a_Squirrel_Body, "frame", new_frame, duration)
	_a_tween.tween_property(_a_Squirrel_Hands, "frame", new_frame, duration)

func _stop_squirrel_hands():
	if _a_tween != null:
		_a_tween.kill()
	_a_Delay.stop()

func _set_squirrel_frame(p_frame):
	_a_Squirrel_Body.set_frame(p_frame)
	_a_Squirrel_Hands.set_frame(p_frame)

func _get_rndm_move_squirrel_dir():
	var frame = _a_Squirrel_Body.get_frame()
	var idx = -1
	if frame < _a_MOVE_SQUIRREL_FRAME_AMOUNTS[0]:
		idx = 1
	elif frame >= _a_MOVE_SQUIRREL_FRAME_AMOUNTS[-1]:
		idx = 0
	else:
		idx = randi() % _a_MOVE_SQUIRREL_DIRS.size()
	var dir = _a_MOVE_SQUIRREL_DIRS[idx]
	
	return dir

func _get_rndm_move_squirrel_frame_amount(p_dir):
	var frame = _a_Squirrel_Body.get_frame()
	var diff = -1
	match p_dir:
		-1: diff = frame
		1: diff = 6 - frame
	
	var mod = 0
	var frame_amounts_size = _a_MOVE_SQUIRREL_FRAME_AMOUNTS.size()
	for i in range(frame_amounts_size, 0, -1):
		var frame_amount = _a_MOVE_SQUIRREL_FRAME_AMOUNTS[i - 1]
		if diff >= frame_amount:
			mod = i
			break
	
	var frame_amount = 0
	if mod != 0:
		var idx = randi() % mod
		frame_amount = _a_MOVE_SQUIRREL_FRAME_AMOUNTS[idx]
	
	return frame_amount

func _CB_cutscene_completed(_p_type, p_key, p_entry_key):
	if p_key == "Squirrel_Fishing_Round_Finish":
		match p_entry_key:
			"Entry":
				_a_Back_Button.set_select_diabled(false)
				
				var amount = _a_Cracked_Peanut_Amount.get_amount()
				if amount > 0:
					set_process_unhandled_input(true)
					_move_squirrel_hands()

func _on_Back_Button_select_pressed():
	close()

func _on_anim_finished(p_name):
	match p_name:
		"Pull_Catch":
			_a_curr_squirrel += 1
	
	if _a_curr_squirrel == _e_squirrels_per_round:
		_a_curr_squirrel = 0
		_finish_round()
	else:
		set_process_unhandled_input(true)
		_move_squirrel_hands()

func _on_Delay_timeout():
	_move_squirrel_hands()

func _on_Tween_finished():
	var delay = randf_range(_e_delay_min, _e_delay_max)
	_a_Delay.start(delay)
