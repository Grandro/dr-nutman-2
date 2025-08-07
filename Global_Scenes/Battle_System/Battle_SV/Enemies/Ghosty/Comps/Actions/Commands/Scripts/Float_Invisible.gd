extends "res://Global_Scenes/Battle_System/Battle_SV/Enemies/Ghosty/Comps/Actions/Commands/Scripts/Attack_ATK.gd"

@export var _e_visible_min : float = 0.5
@export var _e_visible_max : float = 2.0
@export var _e_invisible_min : float = 0.5
@export var _e_invisible_max : float = 2.0

@onready var _a_Timer = get_node("Timer")

func process():
	super()
	var visible_time = randf_range(_e_visible_min, _e_visible_max)
	_a_Timer.timeout.connect(_on_Timer_timeout.bind("Visible"), CONNECT_ONE_SHOT)
	_a_Timer.start(visible_time)

func _on_Timer_timeout(p_state):
	match p_state:
		"Visible":
			var tween = _tween_display_modulate(Color.WHITE, Color.TRANSPARENT)
			tween.finished.connect(_on_Tween_finished)
		"Invisible":
			_tween_display_modulate(Color.TRANSPARENT, Color.WHITE)

func _on_Tween_finished():
	var invisible_time = randf_range(_e_invisible_min, _e_invisible_max)
	_a_Timer.timeout.connect(_on_Timer_timeout.bind("Invisible"), CONNECT_ONE_SHOT)
	_a_Timer.start(invisible_time)
