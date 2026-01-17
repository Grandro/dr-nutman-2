extends ObjectEnemyCompBehaviorStatesStateBase
class_name ObjectEnemyCompBehaviorStatesStateMove

@export_enum("Rndm", "Chase", "Avoid") var _e_type: String = "Rndm"
@export var _e_move_state: StringName = &"Walk"
@export var _e_min_radius: float = 2.0
@export var _e_max_radius: float = 5.0

var _a_nav_agent_comp: CompMovementNavAgent3D

func init(p_behavior: ObjectEnemyCompBehaviorBase, p_entity: Node3D, p_entity_comph: CompHandler) -> void:
	super(p_behavior, p_entity, p_entity_comph)
	_a_nav_agent_comp = p_entity_comph.get_comp("Movement/Nav_Agent")

func process_start() -> void:
	match _e_type:
		&"Rndm": _process_rndm()
		&"Chase": _process_chase()
		&"Avoid": _process_avoid()

func process_end() -> void:
	if _a_nav_agent_comp.path_finished.is_connected(_on_Nav_Agent_path_finished):
		_a_nav_agent_comp.path_finished.disconnect(_on_Nav_Agent_path_finished)
	_a_nav_agent_comp.set_path([])
	_move_to_finished()

func _process_rndm() -> void:
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var point_args: Array = [entity_pos, _e_min_radius, _e_max_radius]
	_move_to(_get_point_circle, point_args)

func _process_chase() -> void:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	var to_vec: Vector3 = target_pos - entity_pos
	var point_args: Array = [entity_pos, to_vec, _e_min_radius, _e_max_radius]
	_move_to(_get_point_rotated, point_args)

func _process_avoid() -> void:
	var target: Node3D = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	var away_vec: Vector3 = entity_pos - target_pos
	var point_args: Array = [entity_pos, away_vec, _e_min_radius, _e_max_radius]
	_move_to(_get_point_rotated, point_args)

func _move_to(p_point_func: Callable, p_point_args: Array) -> void:
	var intersect_params: PhysicsPointQueryParameters3D = _get_intersect_params()
	var world_3d: World3D = _a_entity.get_world_3d()
	var nav_map: RID = world_3d.get_navigation_map()
	var space_state: PhysicsDirectSpaceState3D = world_3d.get_direct_space_state()
	var pos: Vector3 = Vector3.ZERO
	var try: int = 0
	p_point_args.push_back(try)
	
	var in_stay_area: bool = false
	while !in_stay_area:
		p_point_args[-1] = try
		pos = p_point_func.callv(p_point_args)
		pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
		
		if _is_point_in_stay_area(pos, intersect_params, space_state):
			in_stay_area = true
			break
		
		if try == 10:
			# Give up
			_move_to_finished()
			processed.emit()
			return
		
		try += 1
	
	_a_entity_comph.call_comp("States", &"set_state", [_e_move_state])
	_a_entity_comph.call_comp("Anims", &"update_anim")
	
	_a_nav_agent_comp.path_finished.connect(_on_Nav_Agent_path_finished, CONNECT_ONE_SHOT)
	_a_nav_agent_comp.set_path([pos])

func _move_to_finished() -> void:
	_a_entity_comph.call_comp("States", &"set_state", [&"Stop"])
	_a_entity_comph.call_comp("Anims", &"update_anim")

func _get_intersect_params() -> PhysicsPointQueryParameters3D:
	var intersect_params: PhysicsPointQueryParameters3D = PhysicsPointQueryParameters3D.new()
	intersect_params.set_collide_with_areas(true)
	intersect_params.set_collide_with_bodies(false)
	intersect_params.set_collision_mask(128)
	
	return intersect_params

func _is_point_in_stay_area(p_point: Vector3, p_intersect_params: PhysicsPointQueryParameters3D, p_space_state: PhysicsDirectSpaceState3D) -> bool:
	p_intersect_params.set_position(p_point)
	var intersect_args: Array[Dictionary] = p_space_state.intersect_point(p_intersect_params)
	var stay_area: Area3D = _a_behavior.get_stay_area()
	for args: Dictionary in intersect_args:
		if args[&"collider"] == stay_area:
			return true
	
	return false

func _get_point_rotated(p_from: Vector3, p_to_vec: Vector3, p_min_radius: float, p_max_radius: float, p_try: int) -> Vector3:
	# Rotate to_vec by -x° - x°
	# Increase angle range in every try
	var angle_range: int = 18 * p_try
	var rndm_angle_deg: float = randi() % (angle_range + 1) - (angle_range / 2.0)
	var rndm_angle_rad: float = deg_to_rad(rndm_angle_deg)
	var length: float = randf_range(p_min_radius, p_max_radius)
	var point: Vector3 = p_from
	p_to_vec = p_to_vec.rotated(Vector3(0, 1, 0), rndm_angle_rad)
	p_to_vec = p_to_vec.limit_length(length)
	point += p_to_vec
	
	return point

func _get_point_circle(p_from: Vector3, p_min_radius: float, p_max_radius: float, _p_try: int) -> Vector3:
	var point2D: Vector2 = Global.get_rndm_point_circle(p_min_radius, p_max_radius)
	var point3D: Vector3 = p_from + Vector3(point2D.x, 0.0, point2D.y)
	
	return point3D

func _on_Nav_Agent_path_finished() -> void:
	_move_to_finished()
	processed.emit()
