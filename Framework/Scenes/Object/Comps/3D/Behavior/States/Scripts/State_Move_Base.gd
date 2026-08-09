extends FWObjectCompBehaviorStatesStateBase
class_name FWObjectCompBehaviorStatesStateMoveBase

@export var _e_move_state: StringName = &"Walk"
@export var _e_reset_on_finish: bool = true
@export var _e_min_radius: float = 2.0
@export var _e_max_radius: float = 5.0

var _a_nav_agent_comp: FWCompMovementNavAgent3D
var _a_try: int = 0

func init(p_behavior: FWObjectCompBehaviorBase, p_entity: Node3D, p_entity_comph: FWCompHandler) -> void:
	super(p_behavior, p_entity, p_entity_comph)
	_a_nav_agent_comp = p_entity_comph.get_comp("Movement/Nav_Agent")

func process_start() -> void:
	var intersect_params: PhysicsPointQueryParameters3D = _get_intersect_params()
	var world_3d: World3D = _a_entity.get_world_3d()
	var nav_map: RID = world_3d.get_navigation_map()
	var space_state: PhysicsDirectSpaceState3D = world_3d.get_direct_space_state()
	var pos: Vector3 = Vector3.ZERO
	_a_try = 0
	
	while true:
		pos = _get_point()
		pos = NavigationServer3D.map_get_closest_point(nav_map, pos)
		if _is_point_in_stay_area(pos, intersect_params, space_state):
			break
		
		if _a_try == 10:
			# Give up
			_move_to_finished()
			await get_tree().process_frame
			processed.emit()
			return
		_a_try += 1
	
	_a_entity_comph.call_comp("States", &"set_state", [_e_move_state])
	_a_entity_comph.call_comp("Anims", &"update_anim")
	
	if !_e_use_process_time:
		_a_nav_agent_comp.path_finished.connect(_on_Nav_Agent_path_finished, CONNECT_ONE_SHOT)
	super()
	_a_nav_agent_comp.set_path([pos])

func process_end() -> void:
	if _a_nav_agent_comp.path_finished.is_connected(_on_Nav_Agent_path_finished):
		_a_nav_agent_comp.path_finished.disconnect(_on_Nav_Agent_path_finished)
	_a_nav_agent_comp.set_path([])
	super()
	_move_to_finished()

func _move_to_finished() -> void:
	if _e_reset_on_finish:
		_a_entity_comph.call_comp("States", &"set_state", [&"Stop"])
		_a_entity_comph.call_comp("Anims", &"update_anim")

func _get_intersect_params() -> PhysicsPointQueryParameters3D:
	var intersect_params: PhysicsPointQueryParameters3D = PhysicsPointQueryParameters3D.new()
	intersect_params.set_collide_with_areas(true)
	intersect_params.set_collide_with_bodies(false)
	intersect_params.set_collision_mask(128)
	
	return intersect_params

func _is_point_in_stay_area(p_point: Vector3, p_intersect_params: PhysicsPointQueryParameters3D, p_space_state: PhysicsDirectSpaceState3D) -> bool:
	var stay_area: Area3D = _a_behavior.get_stay_area()
	if stay_area == null:
		return true
	
	p_intersect_params.set_position(p_point)
	var intersect_args: Array[Dictionary] = p_space_state.intersect_point(p_intersect_params)
	for args: Dictionary in intersect_args:
		if args[&"collider"] == stay_area:
			return true
	
	return false

func _get_point() -> Vector3:
	return Vector3.ZERO

func _get_point_rotated(p_from: Vector3, p_to_vec: Vector3, p_min_radius: float, p_max_radius: float) -> Vector3:
	# Rotate to_vec by -x° - x°
	# Increase angle range in every try
	var angle_range: int = 18 * _a_try
	var rndm_angle_deg: float = randi() % (angle_range + 1) - (angle_range / 2.0)
	var rndm_angle_rad: float = deg_to_rad(rndm_angle_deg)
	var length: float = randf_range(p_min_radius, p_max_radius)
	
	p_to_vec = p_to_vec.rotated(Vector3(0, 1, 0), rndm_angle_rad)
	if p_to_vec.length() < p_min_radius:
		p_to_vec = p_to_vec.normalized() * p_min_radius
	elif p_to_vec.length() > p_max_radius:
		p_to_vec = p_to_vec.normalized() * p_max_radius
	var point: Vector3 = p_from + p_to_vec
	
	return point

func _get_point_circle(p_from: Vector3, p_min_radius: float, p_max_radius: float) -> Vector3:
	var point_2D: Vector2 = Global.get_rndm_point_circle(p_min_radius, p_max_radius)
	var point_3D: Vector3 = p_from + Vector3(point_2D.x, 0.0, point_2D.y)
	
	return point_3D

func _on_Process_Time_timeout() -> void:
	_a_nav_agent_comp.set_path([])
	_move_to_finished()
	super()

func _on_Nav_Agent_path_finished() -> void:
	_move_to_finished()
	processed.emit()
