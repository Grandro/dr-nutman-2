extends "res://Scenes/Mini_Games/Color_Selection/Game/Scripts/Game_Base.gd"

@export var _e_total_spurt: int = 6 # Total amount of spurts until game end
@export var _e_check_end_time: int = 2 # Seconds to check if all Paint_Drop instances reached the floor
@export var _e_force_end_time: int = 10 # Time after last spurt to when end is forced

var _a_Paint_Drop_Scene = preload("res://Scenes/Mini_Games/Color_Selection/Game/Paint_Drop.tscn")

@onready var _a_Countdown = get_node("Canvas_2/Countdown")
@onready var _a_Result = get_node("Canvas_2/Result")
@onready var _a_Syringe = get_node("Node2D/Syringe")
@onready var _a_Paint_Drops = get_node("Node2D/Paint_Drops")
@onready var _a_Floor_Area_Left = get_node("Node2D/Floor_Areas/Left")
@onready var _a_Floor_Area_Right = get_node("Node2D/Floor_Areas/Right")
@onready var _a_Floor_Area_Glass_Bowl = get_node("Node2D/Floor_Areas/Glass_Bowl")
@onready var _a_Check_End_Timer = get_node("Node2D/Check_End_Timer")
@onready var _a_Force_End_Timer = get_node("Node2D/Force_End_Timer")

var _a_colors = [Color.RED, Color.GREEN, Color.BLUE] # Array to select random colors
var _a_color = null # Current randomly selected color
var _a_glass_bowl_instances = [] # Paint_Drop instances currently in glass bowl
var _a_spurt_count = 0 # Count spurt sequences

func _ready():
	super()
	_a_Countdown.finished.connect(_on_Countdown_finished)
	_a_Result.ok_pressed.connect(_on_Result_ok_pressed)
	_a_Result.play_again_pressed.connect(_on_Result_play_again_pressed)
	_a_Syringe.request_paint_drop.connect(_on_Syringe_request_paint_drop)
	_a_Syringe.completed_spurt_sequence.connect(_on_Syringe_completed_spurt_sequence)
	_a_Floor_Area_Left.body_entered.connect(_on_Floor_Area_Side_body_entered)
	_a_Floor_Area_Left.body_exited.connect(_on_Floor_Area_Side_body_exited)
	_a_Floor_Area_Right.body_entered.connect(_on_Floor_Area_Side_body_entered)
	_a_Floor_Area_Right.body_exited.connect(_on_Floor_Area_Side_body_exited)
	_a_Floor_Area_Glass_Bowl.body_entered.connect(_on_Floor_Area_Glass_Bowl_body_entered)
	_a_Floor_Area_Glass_Bowl.body_exited.connect(_on_Floor_Area_Glass_Bowl_body_exited)
	_a_Check_End_Timer.timeout.connect(_on_Check_End_Timer_timeout)
	_a_Force_End_Timer.timeout.connect(_on_Force_End_Timer_timeout)
	
	_a_Next_Color.hide()
	_a_Countdown.hide()
	_a_Result.hide()

func open_(p_show_explanation):
	_a_colors = [Color.RED, Color.GREEN, Color.BLUE]
	_a_glass_bowl_instances.clear()
	_a_spurt_count = 0
	_a_Camera.set_position(_e_camera_end_pos)
	_a_Camera.set_zoom(Vector2.ONE)
	_a_Camera.make_current()
	
	_a_color = _select_rndm_color()
	_a_Next_Color.set_paint_color(_a_color)
	_a_Next_Color.show_paint()
	_a_Next_Color.show()
	super.open()
	
	if p_show_explanation:
		var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
		var key = "Color_Selection_1"
		cutscene_system_si.cutscene(key, "0")
		cutscene_system_si.set_cutscene_completed_cb(key, "0", _CB_cutscene_completed)
	else:
		_a_Countdown.start()

func show_result():
	var fav_color = Global_Data.get_fav_color()
	_a_Result.open(fav_color)

func _finish():
	_a_Next_Color.hide()
	
	var final_color = Vector3.ZERO
	for instance in _a_glass_bowl_instances:
		var color = instance.get_color()
		final_color.x += color.r
		final_color.y += color.g
		final_color.z += color.b
	final_color /= _a_glass_bowl_instances.size()
	final_color = Color(final_color.x, final_color.y, final_color.z)
	
	disable_flippers(true)
	set_physics_process(false)
	
	_a_Result.open(final_color)

func _select_rndm_color():
	randomize()
	
	_a_colors.shuffle()
	var color = _a_colors.pop_back()
	if _a_colors.is_empty():
		_a_colors = [Color.RED, Color.GREEN, Color.BLUE]
	
	return color

func _CB_cutscene_completed(_p_type, p_key, p_entry_key):
	if p_key == "Color_Selection_1":
		match p_entry_key:
			"0":
				# Explanation finished -> Show countdown
				_a_Countdown.start()

func _on_Countdown_finished():
	_a_Syringe.move_down(_a_color)

func _on_Syringe_request_paint_drop(p_pos):
	var instance = _a_Paint_Drop_Scene.instantiate()
	instance.set_modulate(_a_color)
	instance.set_position(p_pos)
	instance.set_on_floor(false)
	instance.set_color(_a_color)
	
	_a_Paint_Drops.add_child(instance)

func _on_Syringe_completed_spurt_sequence():
	_a_spurt_count += 1
	if _a_spurt_count < _e_total_spurt:
		_a_color = _select_rndm_color()
		_a_Next_Color.set_paint_color(_a_color)
		
		_a_Syringe.move_down(_a_color)
	else:
		_a_Check_End_Timer.start(_e_check_end_time)
		_a_Force_End_Timer.start(_e_force_end_time)

func _on_Floor_Area_Side_body_entered(p_instance):
	p_instance.set_on_floor(true)

func _on_Floor_Area_Side_body_exited(p_instance):
	p_instance.set_on_floor(false)

func _on_Floor_Area_Glass_Bowl_body_entered(p_instance):
	p_instance.set_on_floor(true)
	_a_glass_bowl_instances.push_back(p_instance)

func _on_Floor_Area_Glass_Bowl_body_exited(p_instance):
	p_instance.set_on_floor(false)
	_a_glass_bowl_instances.erase(p_instance)

func _on_Check_End_Timer_timeout():
	var finished_ = true
	for child in _a_Paint_Drops.get_children():
		if !child.is_on_floor():
			finished_ = false
			break
	
	if finished_:
		_a_Check_End_Timer.stop()
		_a_Force_End_Timer.stop()
		_finish()

func _on_Force_End_Timer_timeout():
	_a_Check_End_Timer.stop()
	_finish()

func _on_Result_ok_pressed():
	close()

func _on_Result_play_again_pressed():
	for child in _a_Paint_Drops.get_children():
		child.queue_free()
	open_(false)
