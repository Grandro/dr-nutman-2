extends CanvasLayer

@export var _e_rotate_speed : float = 100.0

@onready var _a_Back = get_node("Margin/Options/Back")

var _a_prev_camera = null # Previous camera
var _a_model = null

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	set_process(false)
	hide()

func _process(p_delta):
	if Input.is_action_pressed("Move_Left"):
		_a_model.rotation_degrees.y += _e_rotate_speed * p_delta
	if Input.is_action_pressed("Move_Right"):
		_a_model.rotation_degrees.y -= _e_rotate_speed * p_delta

func open(p_model):
	var global_si = Global.get_singleton(self, "Global")
	_a_prev_camera = global_si.get_curr_camera()
	_a_model = p_model
	
	var curr_camera = p_model.get_camera()
	var player = global_si.get_player()
	global_si.set_curr_camera(curr_camera)
	player.comph().call_comp("Operate", "disable")
	
	set_process(true)
	show()

func _close():
	var global_si = Global.get_singleton(self, "Global")
	var player = global_si.get_player()
	global_si.set_curr_camera(_a_prev_camera)
	player.comph().call_comp("Operate", "enable")
	
	set_process(false)
	hide()

func _on_Back_select_pressed():
	_close()
