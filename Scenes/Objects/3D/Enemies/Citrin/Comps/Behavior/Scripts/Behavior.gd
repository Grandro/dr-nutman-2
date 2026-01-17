extends ObjectEnemyCompBehaviorBase
class_name ObjectEnemyCitrinCompBehavior

@export var _e_citrin_ball_cd_time: float = 8.0
@export var _e_citrin_ball_radius: float = 4.0
@export var _e_citrin_ball_speed: float = 10.0

var _a_Citrin_Ball_Scene: PackedScene = preload("res://Scenes/Objects/3D/Enemies/Citrin/Citrin_Ball.tscn")

@onready var _a_Enemy_Range: Area3D = get_node("Enemy_Range")
@onready var _a_Citrin_Balls: Node3D = get_node("Citrin_Balls")
@onready var _a_Citrin_Balls_Pos: Marker3D = get_node("Citrin_Balls/Pos")
@onready var _a_Citrin_Ball_CD: Timer = get_node("Citrin_Ball_CD")

var _a_socialize_instance: SVEnemyCitrin

func socialize(p_body: SVEnemyCitrin) -> void:
	_a_socialize_instance = p_body
	_set_state(&"Socialize")

func _process_state() -> void:
	match _a_state:
		&"Avoid":
			if _a_Citrin_Ball_CD.get_time_left() == 0.0:
				_set_queued_state(&"Chase")
		
		&"Chase":
			var entity_pos: Vector3 = _a_entity.get_global_position()
			var target_pos: Vector3 = _a_target.get_global_position()
			var to_vec: Vector3 = target_pos - entity_pos
			var distance: float = to_vec.length()
			if distance <= _e_citrin_ball_radius:
				_set_queued_state(&"Attack")
	
	super()

func _shoot_citrin_ball() -> void:
	var citrin_ball_pos: Vector3 = _a_Citrin_Balls_Pos.get_global_position()
	var target_pos: Vector3 = _a_target.get_global_position()
	target_pos.y += 1.8
	var to_vec: Vector3 = target_pos - citrin_ball_pos
	to_vec = to_vec.normalized()
	
	var instance: ObjectCitrinBall = _a_Citrin_Ball_Scene.instantiate()
	instance.hit.connect(_on_Citrin_Ball_hit)
	instance.set_target(_a_target)
	instance.add_collision_exception_with(_a_entity)
	instance.apply_central_impulse(to_vec * _e_citrin_ball_speed)
	
	_a_Citrin_Balls.add_child(instance)
	instance.set_global_position(citrin_ball_pos)
	
	_a_Citrin_Ball_CD.start(_e_citrin_ball_cd_time)

func get_socialize_instance() -> SVEnemyCitrin:
	return _a_socialize_instance

func _set_keep_state(p_keep_state: bool) -> void:
	super(p_keep_state)
	_a_Enemy_Range.set_monitoring(!p_keep_state)

func load_data(p_data: Dictionary) -> void:
	await _a_entity_comph.comps_registered
	
	var state: StringName = p_data[&"State"]
	match state:
		&"Socialize": _set_state(&"Rndm")
		_: super(p_data)

func load_data_init() -> void:
	await _a_entity_comph.comps_registered
	
	_set_state(&"Rndm")

func _on_Comp_Handler_comps_registered() -> void:
	super()
	_a_Enemy_Range.body_entered.connect(_on_Enemy_Range_body_entered)

func _on_State_processed(p_state: StringName) -> void:
	match p_state:
		&"Attack": _set_state(&"Avoid")
		&"Socialize": _set_state(&"Rndm")
		_: super(p_state)

func _on_Target_Range_body_entered(_p_body) -> void:
	if _a_Citrin_Ball_CD.get_time_left() == 0.0:
		_set_queued_state(&"Chase")
	else:
		_set_queued_state(&"Avoid")

func _on_Target_Range_body_exited(_p_body) -> void:
	_set_queued_state(&"Rndm")

func _on_Enemy_Range_body_entered(p_body) -> void:
	# ToDo: Check if p_body is another Citrin
	if p_body == _a_entity:
		return
	
	if !get_keep_state():
		if !p_body.comph().call_comp("Behavior", &"get_keep_state"):
			p_body.comph().call_comp("Behavior", &"socialize", [_a_entity])
			socialize(p_body)

func _on_Citrin_Ball_hit(p_instance) -> void:
	if p_instance == _a_target:
		var res: BattleSV.MAP_RES = BattleSV.MAP_RES.ENEMY
		_a_entity_comph.call_comp("Battle_Starter", &"start_battle", [res])
