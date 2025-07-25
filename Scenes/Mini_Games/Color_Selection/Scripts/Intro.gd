extends "res://Scenes/Mini_Games/Mini_Game_Base/Scripts/Intro.gd"

@export var _e_camera_start_pos: Vector2 = Vector2(640, 464)
@export var _e_camera_end_pos: Vector2 = Vector2(640, 1224)

@onready var _a_Preview_Camera = get_node("Margin/VBox/HBox/Left/HBox/VP/VP/Game_Preview/Node2D/Camera")
@onready var _a_Preview_Scroll = get_node("Margin/VBox/HBox/Left/HBox/Scroll")

func _ready():
	super()
	_a_Preview_Scroll.value_changed.connect(_on_Preview_Scroll_value_changed)

func _process(_p_delta):
	var camera_pos = _a_Preview_Camera.get_position()
	var pos_y = camera_pos.y - _e_camera_start_pos.y
	var end_y = _e_camera_end_pos.y - _e_camera_start_pos.y
	var value = pos_y / end_y * 100
	_a_Preview_Scroll.set_value(value)

func open():
	_a_Preview_Camera.set_position(_e_camera_start_pos)
	_a_Preview_Camera.set_zoom(Vector2(0.9, 0.9))
	_a_Preview_Camera.make_current_()
	super()

func _on_Preview_Scroll_value_changed(p_value):
	var pos_y = lerp(_e_camera_start_pos.y, _e_camera_end_pos.y, p_value / 100)
	_a_Preview_Camera.position.y = pos_y

func _on_anim_finished(p_anim_name):
	match p_anim_name:
		"Fade_In": _a_game_preview.disable_flippers(false)
		"Fade_Out": _a_game_preview.disable_flippers(true)
	super(p_anim_name)
