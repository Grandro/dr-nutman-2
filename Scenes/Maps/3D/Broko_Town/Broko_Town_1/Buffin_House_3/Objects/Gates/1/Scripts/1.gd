extends "res://Scenes/Object/Scripts/Static3D_Object.gd"

signal opened()

@onready var _a_States = get_node("States")
@onready var _a_Anims = get_node("Anims")

func _ready():
	super()
	_a_States.state_tmp_changed.connect(_on_States_state_tmp_changed)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func _on_States_state_tmp_changed(p_state_tmp):
	var anim_name = _a_Anims.get_current_animation()
	var adjust_speed_scale = false
	if p_state_tmp == "Open" && anim_name == "Close":
		adjust_speed_scale = true
	elif p_state_tmp == "Close" && anim_name == "Open":
		adjust_speed_scale = true
	
	var speed_scale = 1.0
	if adjust_speed_scale:
		var anim_pos = _a_Anims.get_current_animation_position()
		var anim_length = _a_Anims.get_current_animation_length()
		var ratio = anim_pos / anim_length
		speed_scale = 1.0 / ratio
	_a_Anims.set_speed_scale(speed_scale)

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Open":
			_a_States.set_state("Opened")
			opened.emit()
		"Close":
			_a_States.set_state("Closed")
