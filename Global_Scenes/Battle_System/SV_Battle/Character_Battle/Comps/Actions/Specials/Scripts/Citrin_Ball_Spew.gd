extends SVActionBase
class_name SVActionSpecialCitrinBallSpew

var _a_Citrin_Ball_Scene: PackedScene = preload("res://Scenes/Objects/3D/Enemies/Citrin/Citrin_Ball.tscn")

@onready var _a_Pos: Marker3D = get_node("Pos")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")

var _a_Entity_Audio: CompAudio3D
var _a_Entity_Movement: CompSVMovementCharacter
var _a_Entity_Movement_Nav_Agent: CompMovementNavAgent3D
var _a_Entity_States: CompStates
var _a_Entity_Stats: CompSVStats
var _a_Entity_Anims: CompSVAnims

var _a_citrin_ball_height: float
var _a_citrin_ball_speed: float

func init(p_specials: SVActionsBase, p_entity: SVCharacter) -> void:
	super(p_specials, p_entity)
	_a_Entity_Audio = p_entity.comph().get_comp("Audio")
	_a_Entity_Movement = p_entity.comph().get_comp("Movement")
	_a_Entity_Movement_Nav_Agent = p_entity.comph().get_comp("Movement/Nav_Agent")
	_a_Entity_States = p_entity.comph().get_comp("States")
	_a_Entity_Stats = p_entity.comph().get_comp("Stats")
	_a_Entity_Anims = p_entity.comph().get_comp("Anims")
	
	_a_Entity_Movement_Nav_Agent.path_finished.connect(_on_Entity_Movement_Nav_Agent_path_finished)
	_a_Entity_Anims.animation_started.connect(_on_Entity_Anims_anim_started)
	_a_Entity_Anims.animation_finished.connect(_on_Entity_Anims_anim_finished)

func process() -> void:
	var arg: ActionData = _a_actions.get_arg(&"Citrin_Ball_Spew")
	var cost: int = arg.get_SP_cost()
	_a_Entity_Stats.decrease_curr_stat(&"SP", cost)
	
	var pos: Vector3 = _a_entity.get_target_attack_pos()
	pos += Vector3(2.0, 0.0, 0.0)
	_a_Entity_States.set_state(&"Walk")
	_a_Entity_Movement.set_state(&"Move_To_Target")
	_a_Entity_Movement.move_to_pos(pos)
	_a_Entity_Anims.update_anim()
	
	started.emit()
	reaction_started.emit()

func _moved_to_target() -> void:
	var rndm: int = randi() % 10
	if rndm <= 6:
		# Shoot straight at target
		_a_citrin_ball_height = 1.5
		_a_citrin_ball_speed = 5.0
		_a_Entity_States.set_state(&"Shoot")
		_a_Entity_Anims.update_anim()
		
		pre_event.emit()
	else:
		# Shoot above target, indicated by a cry
		_a_citrin_ball_height = 2.3
		_a_citrin_ball_speed = 7.0
		_a_Entity_States.set_state(&"Cry")
		_a_Entity_Anims.update_anim()

func _shoot_citrin_ball() -> void:
	var pos: Vector3 = _a_Pos.get_global_position()
	var target: SVCharacter = _a_entity.get_target()
	var target_pos: Vector3 = target.get_global_position()
	target_pos.y = _a_citrin_ball_height
	var to_vec: Vector3 = pos.direction_to(target_pos)
	
	var instance: ObjectCitrinBall = _a_Citrin_Ball_Scene.instantiate()
	instance.hit.connect(_on_Citrin_Ball_hit)
	instance.set_target(target)
	instance.apply_central_impulse(to_vec * _a_citrin_ball_speed)
	instance.add_collision_exception_with(_a_entity)
	
	_a_entity.add_child(instance)
	instance.set_global_position(pos)

func _on_Entity_Movement_Nav_Agent_path_finished() -> void:
	var state: StringName = _a_Entity_Movement.get_state()
	match state:
		&"Move_To_Target":
			_moved_to_target()
		&"Move_To_Org_Pos":
			_a_Entity_States.set_state(&"Idle")
			_a_Entity_Movement.reset_dir()
			_a_Entity_Anims.update_anim()
			_finished()

func _on_Entity_Anims_anim_started(p_name: StringName) -> void:
	if "Shoot" in p_name:
		_a_Anims.play(p_name)

func _on_Entity_Anims_anim_finished(p_name: StringName) -> void:
	if "Cry" in p_name:
		_a_Entity_States.set_state(&"Shoot")
		_a_Entity_Anims.update_anim()
		
		pre_event.emit()
	
	elif "Shoot" in p_name:
		post_event.emit()
		
		_a_Entity_States.set_state(&"Walk")
		_a_Entity_Movement.set_state(&"Move_To_Org_Pos")
		_a_Entity_Movement.move_to_org_pos()
		_a_Entity_Anims.update_anim()
		await get_tree().create_timer(0.3).timeout
		
		reaction_finished.emit()

func _on_Citrin_Ball_hit(_p_instance: Node3D) -> void:
	_a_Entity_Audio.play("Hit")
	hit.emit()
