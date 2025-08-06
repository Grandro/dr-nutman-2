extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Actions/Scripts/Action_Base.gd"

var _a_Citrin_Ball_Scene = preload("res://Scenes/Objects/3D/Enemies/Citrin/Citrin_Ball.tscn")

@onready var _a_Pos = get_node("Pos")
@onready var _a_Anims = get_node("Anims")

var _a_Entity_Audio = null
var _a_Entity_Movement = null
var _a_Entity_Movement_Nav_Agent = null
var _a_Entity_States = null
var _a_Entity_Stats = null
var _a_Entity_Anims = null

var _a_citrin_ball_height = -1.0
var _a_citrin_ball_speed = -1.0

func init(p_specials, p_entity):
	super(p_specials, p_entity)
	_a_Entity_Audio = p_entity.comph().get_comp("Audio")
	_a_Entity_Movement = p_entity.comph().get_comp("Movement")
	_a_Entity_Movement_Nav_Agent = p_entity.comph().get_subcomp("Movement", "Nav_Agent")
	_a_Entity_States = p_entity.comph().get_comp("States")
	_a_Entity_Stats = p_entity.comph().get_comp("Stats")
	_a_Entity_Anims = p_entity.comph().get_comp("Anims")
	
	_a_Entity_Movement_Nav_Agent.path_finished.connect(_on_Entity_Movement_Nav_Agent_path_finished)
	_a_Entity_Anims.animation_started.connect(_on_Entity_Anims_anim_started)
	_a_Entity_Anims.animation_finished.connect(_on_Entity_Anims_anim_finished)

func process():
	var arg = _a_actions.get_arg("Citrin_Ball_Spew")
	var SP_cost = arg.get_SP_cost()
	_a_Entity_Stats.decrease_curr_stat("SP", SP_cost)
	
	var pos = _a_entity.get_target_attack_pos()
	pos += Vector3(2.0, 0.0, 0.0)
	_a_Entity_States.set_state("Walk")
	_a_Entity_Movement.set_state("Move_To_Target")
	_a_Entity_Movement.move_to_pos(pos)
	_a_Entity_Anims.update_anim()
	
	started.emit()
	reaction_started.emit()

func _moved_to_target():
	var rndm = randi() % 10
	if rndm <= 6:
		# Shoot straight at target
		_a_citrin_ball_height = 1.5
		_a_citrin_ball_speed = 5.0
		_a_Entity_States.set_state("Shoot")
		_a_Entity_Anims.update_anim()
		
		pre_event.emit()
	else:
		# Shoot above target, indicated by a cry
		_a_citrin_ball_height = 2.3
		_a_citrin_ball_speed = 7.0
		_a_Entity_States.set_state("Cry")
		_a_Entity_Anims.update_anim()

func _shoot_citrin_ball():
	var pos = _a_Pos.get_global_position()
	var target = _a_entity.get_target()
	var target_pos = target.get_global_position()
	target_pos.y = _a_citrin_ball_height
	var to_vec = pos.direction_to(target_pos)
	
	var instance = _a_Citrin_Ball_Scene.instantiate()
	instance.hit.connect(_on_Citrin_Ball_hit)
	instance.set_target(target)
	instance.apply_central_impulse(to_vec * _a_citrin_ball_speed)
	instance.add_collision_exception_with(_a_entity)
	
	_a_entity.add_child(instance)
	instance.set_global_position(pos)

func _on_Entity_Movement_Nav_Agent_path_finished():
	var state = _a_Entity_Movement.get_state()
	match state:
		"Move_To_Target":
			_moved_to_target()
		"Move_To_Org_Pos":
			_a_Entity_States.set_state("Idle")
			_a_Entity_Movement.reset_dir()
			_a_Entity_Anims.update_anim()
			_finished()

func _on_Entity_Anims_anim_started(p_name):
	if "Shoot" in p_name:
		_a_Anims.play(p_name)

func _on_Entity_Anims_anim_finished(p_name):
	if "Cry" in p_name:
		_a_Entity_States.set_state("Shoot")
		_a_Entity_Anims.update_anim()
		
		pre_event.emit()
	
	elif "Shoot" in p_name:
		post_event.emit()
		
		_a_Entity_States.set_state("Walk")
		_a_Entity_Movement.set_state("Move_To_Org_Pos")
		_a_Entity_Movement.move_to_org_pos()
		_a_Entity_Anims.update_anim()
		await get_tree().create_timer(0.3).timeout
		
		reaction_finished.emit()

func _on_Citrin_Ball_hit(_p_instance):
	_a_Entity_Audio.play("Hit")
	hit.emit()
