extends "res://Global_Scenes/Battle_System/Battle_SV/Enemies/Scripts/Enemy_Battle.gd"

var _a_Citrin_Ball_Scene = preload("res://Scenes/Objects/3D/Enemies/Citrin/Citrin_Ball.tscn")

@onready var _a_Audio = get_node("Audio")
@onready var _a_States = get_node("States")
@onready var _a_Stats = get_node("Stats")
@onready var _a_Movement = get_node("Movement")
@onready var _a_Movement_Nav_Agent = get_node("Movement/Nav_Agent")
@onready var _a_Citrin_Balls = get_node("Citrin_Balls")
@onready var _a_Citrin_Balls_Pos = get_node("Citrin_Balls/Pos")
@onready var _a_Anims = get_node("Anims")

var _a_citrin_ball_height = -1.0
var _a_citrin_ball_speed = -1.0

func _ready():
	super()
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func process_action_start():
	# Possible actions:
	# 1) Melee attack: 0.7
	# 2) Special: Citrin ball (Straight / Up): 0.3
	var SP = _a_Stats.get_curr_stat("SP")
	var rndm = randi() % 10
	if rndm <= 6 || SP < 3:
		# Meele attack
		_process_attack()
	else:
		_process_special()

func _process_attack():
	_a_command = "Attack_ATK"
	
	_pick_target()
	var pos = _get_target_attack_pos()
	_a_States.set_state("Walk")
	_a_Movement.set_state("Move_To_Target")
	_a_Movement.move_to_pos(pos)
	_a_Anims.update_anim()
	
	attack_pm_started.emit(_a_target)

func _process_special():
	_a_command = "Special"
	_a_special = "Citrin_Ball_Spew"
	
	var args = _a_actions_data["Specials"][_a_special]
	var SP_cost = args.get_SP_cost()
	_a_Stats.decrease_curr_stat("SP", SP_cost)
	_pick_target()
	
	var pos = _get_target_attack_pos()
	pos += Vector3(2.0, 0.0, 0.0)
	_a_States.set_state("Walk")
	_a_Movement.set_state("Move_To_Target")
	_a_Movement.move_to_pos(pos)
	_a_Anims.update_anim()
	
	attack_pm_started.emit(_a_target)

func _process_citrin_ball_moved_to():
	var rndm = randi() % 10
	if rndm <= 6:
		# Shoot straight at target
		_a_citrin_ball_height = 1.5
		_a_citrin_ball_speed = 5.0
		_a_States.set_state("Shoot")
		_a_Anims.update_anim()
	else:
		# Shoot above target, indicated by a cry
		_a_citrin_ball_height = 2.3
		_a_citrin_ball_speed = 7.0
		_a_States.set_state("Cry")
		_a_Anims.update_anim()

func _shoot_citrin_ball():
	var citrin_ball_pos = _a_Citrin_Balls_Pos.get_global_position()
	var target_pos = _a_target.get_global_position()
	target_pos.y = _a_citrin_ball_height
	var to_vec = citrin_ball_pos.direction_to(target_pos)
	
	var instance = _a_Citrin_Ball_Scene.instantiate()
	instance.hit.connect(_on_Citrin_Ball_hit)
	instance.set_target(_a_target)
	instance.apply_central_impulse(to_vec * _a_citrin_ball_speed)
	instance.add_collision_exception_with(self)
	
	_a_Citrin_Balls.add_child(instance)
	instance.set_global_position(citrin_ball_pos)

func _moved_to():
	match _a_command:
		"Attack_ATK":
			_a_States.set_state("Attack")
			_a_Anims.update_anim()
		
		"Special":
			_process_citrin_ball_moved_to()

func _on_Hitbox_body_entered(p_body):
	_a_Audio.play("Hit")
	super(p_body)

func _on_Movement_Nav_Agent_path_finished():
	var state = _a_Movement.get_state()
	match state:
		"Move_To_Target":
			_moved_to()
		
		"Move_To_Org_Pos":
			_a_States.set_state("Idle")
			_a_Movement.reset_dir()
			_a_Anims.update_anim()
			_emit_turn_completed()
		
		"Recover_Knockback":
			_a_States.set_state("Idle")
			_a_Movement.reset_dir()
			_a_Anims.update_anim()

func _on_Anims_anim_finished(p_name):
	if "Attack" in p_name:
		_a_States.set_state("Walk")
		_a_Movement.set_state("Move_To_Org_Pos")
		_a_Movement.move_to_org_pos()
		_a_Anims.update_anim()
		await get_tree().create_timer(1.0).timeout
		
		attack_pm_finished.emit(_a_target)
	
	elif "Cry" in p_name:
		_a_States.set_state("Shoot")
		_a_Anims.update_anim()
	
	elif "Shoot" in p_name:
		_a_States.set_state("Walk")
		_a_Movement.set_state("Move_To_Org_Pos")
		_a_Movement.move_to_org_pos()
		_a_Anims.update_anim()
		await get_tree().create_timer(1.0).timeout
		
		attack_pm_finished.emit(_a_target)

func _on_Citrin_Ball_hit(p_instance):
	_a_Audio.play("Hit")
	hit.emit(self, p_instance)
