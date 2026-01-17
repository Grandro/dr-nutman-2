extends MiniGameRightOnTheNutGameBase
class_name MiniGameRightOnTheNutGamePlay

@export var _e_launches_per_round: int = 3
@export var _e_targets_per_launch: int = 5
@export var _e_fragments_per_crack: int = 6

var _a_Cracked_Peanut_Scene: PackedScene = preload("res://Scenes/Mini_Games/Right_On_The_Nut/Game/Cracked_Peanut.tscn")
var _a_Uncracked_Peanut_Fragment_Scene: PackedScene = preload("res://Scenes/Mini_Games/Right_On_The_Nut/Game/Uncracked_Peanut_Fragment.tscn")

@onready var _a_Back_Button: IndicatorButton = get_node("Canvas_2/Margin/Back_Button")
@onready var _a_Uncracked_Peanut_Amount: ItemAmountDisplay = get_node("Canvas_2/Margin/Uncracked_Peanut_Amount")
@onready var _a_Dots: Node2D = get_node("Node2D/Dots")
@onready var _a_Dot_1: MiniGameRightOnTheNutDot = get_node("Node2D/Dots/1")
@onready var _a_Dot_10: MiniGameRightOnTheNutDot = get_node("Node2D/Dots/10")
@onready var _a_Nutcracker_Jaw: Sprite2D = get_node("Node2D/Nutcracker_Jaw")
@onready var _a_Nutcracker_Jaw_Delay: Timer = get_node("Node2D/Nutcracker_Jaw/Delay")
@onready var _a_Nutcracker_Jaw_Anims: AnimationPlayer = get_node("Node2D/Nutcracker_Jaw/Anims")
@onready var _a_Uncracked_Peanut: Sprite2D = get_node("Node2D/Uncracked_Peanut")
@onready var _a_Uncracked_Peanut_Camera: CompCamera2D = get_node("Node2D/Uncracked_Peanut/Camera")
@onready var _a_Peanut_Fragments: Node2D = get_node("Node2D/Peanut_Fragments")
@onready var _a_Crack_Delay: Timer = get_node("Node2D/Crack_Delay")
@onready var _a_Audio_Launch_Nut: AudioStreamPlayer = get_node("Node2D/Audio/Launch_Nut")
@onready var _a_Audio_Nutcracker_Bite: AudioStreamPlayer = get_node("Node2D/Audio/Nutcracker_Bite")

var _a_tween: Tween = null
var _a_curr_round: int = 0
var _a_curr_target: int = 0
var _a_finished_round: bool = false

func _ready() -> void:
	super()
	_a_Back_Button.select_pressed.connect(_on_Back_Button_select_pressed)
	_a_QT_Bar.stopped.connect(_on_QT_Bar_stopped)
	_a_Nutcracker_Jaw_Delay.timeout.connect(_on_Nutcracker_Jaw_Delay_timeout)
	_a_Nutcracker_Jaw_Anims.animation_finished.connect(_on_Nutcracker_Jaw_anim_finished)
	_a_Crack_Delay.timeout.connect(_on_Crack_Delay_timeout)
	
	set_process(false)
	
	_a_Back_Button.hide()
	_a_Uncracked_Peanut_Amount.hide()
	_a_Uncracked_Peanut.hide()

func _process(_p_delta: float) -> void:
	var uncracked_peanut_pos: Vector2 = _a_Uncracked_Peanut.get_position()
	for child: MiniGameRightOnTheNutDot in _a_Dots.get_children():
		var child_pos: Vector2 = child.get_position()
		var progress: float = ((child_pos.y + 28.0) - uncracked_peanut_pos.y) / 57.0
		progress = min(1.0, progress)
		progress = max(0.0, progress)
		child.set_inner_progress(progress)

func open() -> void:
	_a_Uncracked_Peanut_Camera.make_current()
	
	set_process(true)
	_crack_sequence(true)
	
	super()
	_a_Back_Button.show()
	_a_Uncracked_Peanut_Amount.show()
	_a_Uncracked_Peanut.show()

func close() -> void:
	set_process(false)
	_a_diff = 0
	_a_curr_round = 0
	_a_curr_target = 0
	_a_Nutcracker_Jaw_Delay.stop()
	_a_Crack_Delay.stop()
	_a_Nutcracker_Jaw.set_z_index(0)
	_a_Nutcracker_Jaw_Anims.play(&"RESET")
	if _a_tween != null:
		_a_tween.kill()
	
	close_qt_bar()
	_a_Back_Button.hide()
	_a_Uncracked_Peanut_Amount.hide()
	super()

func _finish_round() -> void:
	_a_finished_round = true
	_a_Back_Button.set_select_diabled(true)
	
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var key: StringName = &"Right_On_The_Nut_Round_Finish"
	cutscene_system_si.cutscene(key, &"Entry", &"Main", &"Global")
	cutscene_system_si.set_cutscene_completed_cb(key, &"Entry", _CB_cutscene_completed)

func _crack_sequence(p_first: bool) -> void:
	_a_diff = 2 * _a_curr_target
	if randi() % 2 == 0:
		_a_diff += 1
	
	if p_first:
		open_qt_bar(false)
		var dot_10_pos: Vector2 = _a_Dot_10.get_position()
		_a_Uncracked_Peanut.set_position(dot_10_pos)
	else:
		_a_QT_Bar.update_target(_a_diff)
		_a_QT_Bar.update_custom_speed(_a_diff)

func _launch_nut() -> void:
	close_qt_bar()
	if _a_curr_target == 0:
		_crack_sequence(true)
	else:
		_a_Audio_Launch_Nut.play()
		_move_peanut_up()

func _move_peanut_up() -> void:
	var dot_1_pos: Vector2 = _a_Dot_1.get_position()
	var uncracked_peanut_pos: Vector2 = _a_Uncracked_Peanut.get_position()
	var to_vec: Vector2 = dot_1_pos - uncracked_peanut_pos
	to_vec *= _a_curr_target / float(_e_targets_per_launch)
	
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Uncracked_Peanut_Tween_finished.bind(&"Up"))
	_a_tween.set_trans(Tween.TRANS_QUAD)
	_a_tween.set_ease(Tween.EASE_OUT)
	_a_tween.tween_property(_a_Uncracked_Peanut, "position", to_vec, 2).as_relative()

func _move_peanut_down(p_duration: float) -> void:
	var dot_10_pos: Vector2 = _a_Dot_10.get_position()
	_a_tween = create_tween()
	_a_tween.finished.connect(_on_Uncracked_Peanut_Tween_finished.bind(&"Down"))
	_a_tween.set_trans(Tween.TRANS_QUAD)
	_a_tween.set_ease(Tween.EASE_IN)
	_a_tween.tween_property(_a_Uncracked_Peanut, "position", dot_10_pos, p_duration)

func _instantiate_peanut_fragment(p_scene: PackedScene) -> void:
	var impulse: Vector2 = Vector2.ZERO
	impulse.x = randi() % 401 - 200
	impulse.y = -(randi() % 201) - 100
	var torque: int = randi() % 1000 + 500
	var instance: RigidBody2D = p_scene.instantiate()
	instance.apply_central_impulse(impulse)
	instance.apply_torque_impulse(torque)
	
	_a_Peanut_Fragments.add_child(instance)

func _CB_cutscene_completed(_p_type: StringName, p_key: StringName, p_entry_key: StringName) -> void:
	if p_key == &"Right_On_The_Nut_Round_Finish":
		match p_entry_key:
			&"Entry":
				_a_Back_Button.set_select_diabled(false)
				_a_finished_round = false
				
				var amount: int = _a_Uncracked_Peanut_Amount.get_amount()
				if amount > 0:
					_crack_sequence(true)

func _on_Back_Button_select_pressed() -> void:
	close()

func _on_QT_Bar_stopped(p_on_target: bool) -> void:
	if !p_on_target:
		_launch_nut()
		return
	
	_a_curr_target += 1
	if _a_curr_target == _e_targets_per_launch:
		_launch_nut()
	else:
		_crack_sequence(false)

func _on_Nutcracker_Jaw_Delay_timeout() -> void:
	_a_Nutcracker_Jaw_Anims.play(&"Move_Down")
	_a_Nutcracker_Jaw.set_z_index(0)
	for child: RigidBody2D in _a_Peanut_Fragments.get_children():
		child.queue_free()
	
	for i: int in _e_fragments_per_crack:
		_instantiate_peanut_fragment(_a_Uncracked_Peanut_Fragment_Scene)
	_instantiate_peanut_fragment(_a_Cracked_Peanut_Scene)
	
	_a_Crack_Delay.start()

func _on_Nutcracker_Jaw_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Move_Up":
			_a_Audio_Nutcracker_Bite.play()
			_a_Uncracked_Peanut.hide()
			_a_Nutcracker_Jaw_Delay.start()

func _on_Crack_Delay_timeout() -> void:
	_a_curr_round += 1
	_move_peanut_down(1)
	if _a_curr_round == _e_launches_per_round:
		_a_curr_round = 0
		_finish_round()

func _on_Uncracked_Peanut_Tween_finished(p_state: StringName) -> void:
	match p_state:
		&"Up":
			if _a_curr_target == _e_targets_per_launch:
				_a_Nutcracker_Jaw.set_z_index(1)
				_a_Nutcracker_Jaw_Anims.play(&"Move_Up")
			else:
				_move_peanut_down(2)
			
			_a_curr_target = 0
		
		&"Down":
			var amount: int = _a_Uncracked_Peanut_Amount.get_amount()
			if amount > 0:
				_a_Uncracked_Peanut.show()
			if !_a_finished_round:
				_crack_sequence(true)
