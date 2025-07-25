extends Node3D

enum _a_STATES {RNDM, AVOID, CHASE, ATTACK, SOCIALIZE, IN_BATTLE, RESPAWN}

@export var _e_stay_area: Area3D = null
@export var _e_action_rndm_cd_time: float = 4.0
@export var _e_action_chase_cd_time: float = 0.1
@export var _e_action_avoid_cd_time: float = 0.1
@export var _e_idle_cd_time: float = 1.0
@export var _e_citrin_ball_cd_time: float = 8.0
@export var _e_citrin_ball_radius: float = 4.0
@export var _e_citrin_ball_speed: float = 10.0
@export var _e_move_rndm_min_radius: float = 2.0
@export var _e_move_rndm_max_radius: float = 7.0
@export var _e_chase_min_radius: float = 2.0
@export var _e_chase_max_radius: float = 5.0

var _a_Citrin_Ball_Scene = preload("res://Scenes/Objects/3D/Enemies/Citrin/Citrin_Ball.tscn")

@onready var _a_Debug_State = get_node("Debug_State")
@onready var _a_Debug_Persist = get_node("Debug_Persist")

@onready var _a_Target_Range = get_node("Target_Range")
@onready var _a_Enemy_Range = get_node("Enemy_Range")
@onready var _a_Citrin_Balls = get_node("Citrin_Balls")
@onready var _a_Citrin_Balls_Pos = get_node("Citrin_Balls/Pos")
@onready var _a_Action_CD = get_node("Action_CD")
@onready var _a_Idle_CD = get_node("Idle_CD")
@onready var _a_Citrin_Ball_CD = get_node("Citrin_Ball_CD")

var _a_entity : Character3DObject = null
var _a_entity_comph : CompHandler = null
var _a_nav_agent_comp = null

var _a_nav_server_rdy = false
var _a_target = null
var _a_socialize_instance = null
var _a_state = -1
var _a_queued_state = -1
var _a_persist = false # Don't change _a_state, state, dir

func _process(_p_delta):
	if _a_queued_state != -1:
		_set_state(_a_queued_state)
		_a_queued_state = -1

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)

func socialize(p_body):
	_a_socialize_instance = p_body
	_set_state(_a_STATES.SOCIALIZE)

func _process_actions():
	match _a_state:
		_a_STATES.RNDM: _process_action_rndm()
		_a_STATES.AVOID: _process_action_avoid()
		_a_STATES.CHASE: _process_action_chase()
		_a_STATES.ATTACK: _process_action_attack()
		_a_STATES.SOCIALIZE: _process_action_socialize()
		_a_STATES.IN_BATTLE: _process_action_in_battle()
		_a_STATES.RESPAWN: _process_action_respawn()

func _process_action_rndm():
	_a_Target_Range.set_monitoring(true)
	_a_Enemy_Range.set_monitoring(true)
	
	# Possible actions:
	# 1) Change direction
	# 2) Move at rndm
	var rndm = randi() % 2
	match rndm:
		0:
			# Change dir
			var curr_dir = _a_entity_comph.call_comp("Movement", "get_dir")
			var rndm_dir = Global.get_rndm_dir(curr_dir)
			_a_entity_comph.call_comp("Movement", "set_dir", [rndm_dir])
			_a_entity_comph.call_comp("Anims", "update_anim")
			
			_a_Action_CD.start()
			_a_Idle_CD.start()
		1:
			# Move at rndm
			var entity_pos = _a_entity.get_global_position()
			_move_to(_get_point_circle, [entity_pos])
			
			_a_Action_CD.stop()
			_a_Idle_CD.stop()

func _process_action_avoid():
	if _a_Citrin_Ball_CD.get_time_left() == 0.0:
		_set_state(_a_STATES.CHASE)
		return
	
	_a_Target_Range.set_monitoring(true)
	_a_Enemy_Range.set_monitoring(true)
	
	# Possible actions:
	# 1) Walk away from target
	# When far enough away _a_state will become _a_states.RNDM
	var entity_pos = _a_entity.get_global_position()
	var target_pos = _a_target.get_global_position()
	var away_vec = entity_pos - target_pos
	
	_a_Action_CD.stop()
	_a_Idle_CD.stop()
	
	# Walk away from target
	_move_to(_get_point_rotated, [entity_pos, away_vec])

func _process_action_chase():
	# Is already in range?
	var entity_pos = _a_entity.get_global_position()
	var target_pos = _a_target.get_global_position()
	var to_vec = target_pos - entity_pos
	var distance = to_vec.length()
	if distance <= _e_citrin_ball_radius:
		_set_state(_a_STATES.ATTACK)
		return
	
	_a_Target_Range.set_monitoring(true)
	_a_Enemy_Range.set_monitoring(true)
	
	# Possible actions:
	# 1) Look at target
	# 2) Walk towards target
	var rndm = randi() % 2
	match rndm:
		0:
			# Look at target
			var dir = Global.get_dir_to_pos(entity_pos, target_pos)
			_a_entity_comph.call_comp("Movement", "set_dir", [dir])
			_a_entity_comph.call_comp("Anims", "update_anim")
			_a_Idle_CD.start()
		
		1:
			# Walk towards target
			_move_to(_get_point_rotated, [entity_pos, to_vec])
			
			_a_Action_CD.stop()
			_a_Idle_CD.stop()

func _process_action_attack():
	_a_Target_Range.set_monitoring(false)
	_a_Enemy_Range.set_monitoring(false)

	_a_nav_agent_comp.set_path([])
	
	var entity_pos = _a_entity.get_global_position()
	var target_pos = _a_target.get_global_position()
	var dir = Global.get_dir_to_pos(entity_pos, target_pos)
	_a_entity_comph.call_comp("Movement", "set_dir", [dir])
	_a_entity_comph.call_comp("States", "set_state", ["Shoot"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	_a_Action_CD.stop()
	_a_Idle_CD.stop()
	_set_persist(true)

func _process_action_socialize():
	_a_nav_agent_comp.set_path([])
	
	var entity_pos = _a_entity.get_global_position()
	var body_pos = _a_socialize_instance.get_global_position()
	var dir = Global.get_dir_to_pos(entity_pos, body_pos)
	_a_entity_comph.call_comp("Movement", "set_dir", [dir])
	_a_entity_comph.call_comp("States", "set_state", ["Cry"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	_set_persist(true)

func _process_action_in_battle():
	_a_Target_Range.set_monitoring(false)
	_a_Enemy_Range.set_monitoring(false)

func _process_action_respawn():
	_a_Target_Range.set_monitoring(false)
	_a_Enemy_Range.set_monitoring(false)
	
	var progress_si = Global.get_singleton(self, "Progress")
	var key = _a_entity_comph.call_comp("Reference", "get_key")
	progress_si.call_object(key, "start_respawn")

func _move_to(p_point_func, p_point_args):
	var intersect_params = _get_intersect_params()
	var world_3d = get_world_3d()
	var nav_map = world_3d.get_navigation_map()
	var space_state = world_3d.get_direct_space_state()
	var pos = Vector3.ZERO
	var tries = 0
	p_point_args.push_back(tries)
	
	var in_stay_area = false
	while !in_stay_area:
		p_point_args[-1] = tries
		pos = p_point_func.callv(p_point_args)
		pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
		
		if _is_point_in_stay_area(pos, intersect_params, space_state):
			in_stay_area = true
			break
		
		if tries == 10:
			# Give up
			_move_to_finished()
			return
		
		tries += 1
	
	_a_entity_comph.call_comp("States", "set_state", ["Walk"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	_a_nav_agent_comp.set_path([pos])

func _move_to_finished():
	_a_entity_comph.call_comp("States", "set_state", ["Stop"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	_a_Action_CD.start()
	_a_Idle_CD.start()

func _shoot_citrin_ball():
	var citrin_ball_pos = _a_Citrin_Balls_Pos.get_global_position()
	var target_pos = _a_target.get_global_position()
	target_pos.y += 1.8
	var to_vec = target_pos - citrin_ball_pos
	to_vec = to_vec.normalized()
	
	var instance = _a_Citrin_Ball_Scene.instantiate()
	instance.hit.connect(_on_Citrin_Ball_hit)
	instance.set_target(_a_target)
	instance.add_collision_exception_with(_a_entity)
	instance.apply_central_impulse(to_vec * _e_citrin_ball_speed)
	
	_a_Citrin_Balls.add_child(instance)
	instance.set_global_position(citrin_ball_pos)
	
	_a_Citrin_Ball_CD.start()

func get_state():
	return _a_state

func is_persisting():
	return _a_persist

func _set_state(p_state, p_process_actions = true):
	var state_text = _a_STATES.keys()[p_state]
	_a_Debug_State.set_text(state_text)
	
	match p_state:
		_a_STATES.RNDM: _a_Action_CD.set_wait_time(_e_action_rndm_cd_time)
		_a_STATES.AVOID: _a_Action_CD.set_wait_time(_e_action_avoid_cd_time)
		_a_STATES.CHASE: _a_Action_CD.set_wait_time(_e_action_chase_cd_time)
		_a_STATES.ATTACK: _a_Action_CD.stop()
		_a_STATES.SOCIALIZE: _a_Action_CD.stop()
		_a_STATES.IN_BATTLE: _a_Action_CD.stop()
		_a_STATES.RESPAWN: _a_Action_CD.stop()
	
	_a_state = p_state
	
	if p_process_actions:
		_process_actions()

func _set_persist(p_persist):
	_a_persist = p_persist
	_a_Debug_Persist.set_text(str(p_persist))
	set_process(!p_persist)

func _get_point_circle(p_from, _p_tries):
	var point = Global.get_rndm_point_circle(_e_move_rndm_min_radius, _e_move_rndm_max_radius)
	point = p_from + Vector3(point.x, 0.0, point.y)
	
	return point

func _get_point_rotated(p_from, p_to_vec, p_tries):
	# Rotate to_vec by -x° - x°
	# Increase angle range in every try
	var angle_range = 90 + 12 * p_tries
	var rndm_angle_deg = randi() % (angle_range + 1) - (angle_range / 2)
	var rndm_angle_rad = deg_to_rad(rndm_angle_deg)
	var length = randf_range(_e_chase_min_radius, _e_chase_max_radius)
	var point = p_from
	p_to_vec = p_to_vec.rotated(Vector3(0, 1, 0), rndm_angle_rad)
	p_to_vec = p_to_vec.limit_length(length)
	point += p_to_vec
	
	return point

func _get_intersect_params():
	var intersect_params = PhysicsPointQueryParameters3D.new()
	intersect_params.set_collide_with_areas(true)
	intersect_params.set_collide_with_bodies(false)
	intersect_params.set_collision_mask(128)
	
	return intersect_params

func _is_point_in_stay_area(p_point, p_intersect_params, p_space_state):
	p_intersect_params.set_position(p_point)
	var intersect_args = p_space_state.intersect_point(p_intersect_params)
	for args in intersect_args:
		if args["collider"] == _e_stay_area:
			return true
	
	return false

func get_save_data():
	var data = {}
	data["State"] = _a_state
	
	return data

func load_data(p_data):
	if !_a_nav_server_rdy:
		await NavigationServer3D.map_changed
	
	var state = p_data["State"]
	match state:
		_a_STATES.SOCIALIZE:
			_set_state(_a_STATES.RNDM)
		_a_STATES.IN_BATTLE:
			_set_state(_a_STATES.RESPAWN)
		_a_STATES.RESPAWN:
			var progress_si = Global.get_singleton(self, "Progress")
			var key = _a_entity_comph.call_comp("Reference", "get_key")
			var respawn_rdy = progress_si.call_object(key, "get_respawn_rdy")
			if respawn_rdy:
				_set_state(_a_STATES.RNDM)
				_a_entity.show()
			else:
				_set_state(_a_STATES.RESPAWN, false)
		_:
			_set_state(state)

func load_data_init():
	if !_a_nav_server_rdy:
		await NavigationServer3D.map_changed
	
	_set_state(_a_STATES.RNDM)

func _on_Comp_Handler_comps_registered():
	_a_Target_Range.body_entered.connect(_on_Target_Range_body_entered)
	_a_Target_Range.body_exited.connect(_on_Target_Range_body_exited)
	_a_Enemy_Range.body_entered.connect(_on_Enemy_Range_body_entered)
	_a_Action_CD.timeout.connect(_on_Action_CD_timeout)
	_a_Idle_CD.timeout.connect(_on_Idle_CD_timeout)
	
	_a_Idle_CD.set_wait_time(_e_idle_cd_time)
	_a_Citrin_Ball_CD.set_wait_time(_e_citrin_ball_cd_time)
	
	var global_si = Global.get_singleton(self, "Global")
	_a_target = global_si.get_player()
	
	_a_nav_agent_comp = _a_entity_comph.get_subcomp("Movement", "Nav_Agent")
	var anims_comp = _a_entity_comph.get_comp("Anims")
	var battle_starter_comp = _a_entity_comph.get_comp("Battle_Starter")
	_a_nav_agent_comp.path_finished.connect(_on_Nav_Agent_path_finished)
	anims_comp.animation_finished.connect(_on_Anims_anim_finished)
	battle_starter_comp.battle_starting.connect(_on_Battle_Starter_battle_starting)
	NavigationServer3D.map_changed.connect(_on_Navigation_Server_map_changed)

func _on_Target_Range_body_entered(_p_body):
	if _a_Citrin_Ball_CD.get_time_left() == 0.0:
		_a_queued_state = _a_STATES.CHASE
	else:
		_a_queued_state = _a_STATES.AVOID

func _on_Target_Range_body_exited(_p_body):
	_a_queued_state = _a_STATES.RNDM

func _on_Enemy_Range_body_entered(p_body):
	# ToDo: Check if p_body is another Citrin
	if p_body == _a_entity:
		return
	
	if !is_persisting():
		if !p_body.comph().call_comp("Behaviour", "is_persisting"):
			p_body.comph().call_comp("Behaviour", "socialize", [_a_entity])
			socialize(p_body)

func _on_Action_CD_timeout():
	_process_actions()

func _on_Idle_CD_timeout():
	_a_entity_comph.call_comp("States", "set_state", ["Idle"])
	_a_entity_comph.call_comp("Anims", "update_anim")

func _on_Nav_Agent_path_finished():
	_move_to_finished()

func _on_Anims_anim_finished(p_anim_name):
	if "Shoot" in p_anim_name:
		_a_entity_comph.call_comp("States", "set_state", ["Stop"])
		_a_entity_comph.call_comp("Anims", "update_anim")
		
		_set_state(_a_STATES.AVOID)
		_set_persist(false)
	
	elif "Cry" in p_anim_name:
		_a_entity_comph.call_comp("States", "set_state", ["Stop"])
		_a_entity_comph.call_comp("Anims", "update_anim")
		
		_set_state(_a_STATES.RNDM)
		_set_persist(false)

func _on_Battle_Starter_battle_starting():
	_a_entity_comph.call_comp("States", "set_state", ["Stop"])
	_a_entity_comph.call_comp("Anims", "update_anim")
	
	_set_state(_a_STATES.IN_BATTLE)
	_a_entity.hide()

func _on_Navigation_Server_map_changed(_p_map_rid):
	_a_nav_server_rdy = true

func _on_Citrin_Ball_hit(p_instance):
	if p_instance == _a_target:
		var res = BattleSV.MAP_RES.ENEMY
		_a_entity_comph.call_comp("Battle_Starter", "start_battle", [res])
