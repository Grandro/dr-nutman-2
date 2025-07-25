extends "res://Scenes/Maps/3D/Broko_Town/Broko_Town_1/Objects/Comps/Balloons/Scripts/Container_Base.gd"

@onready var _a_Timer = get_node("Timer")

func _ready():
	_a_Timer.timeout.connect(_on_Timer_timeout)
	
	_apply_balloon_impulse()
	var time = randf_range(4, 8)
	_a_Timer.start(time)

func _apply_balloon_impulse():
	var impulse_x = randf_range(-0.1, 0.1)
	var impulse_z = randf_range(-0.1, 0.1)
	_a_Balloon.apply_central_impulse(Vector3(impulse_x, 0.0, impulse_z))

func _on_Timer_timeout():
	_apply_balloon_impulse()
	var time = randf_range(4, 8)
	_a_Timer.start(time)
