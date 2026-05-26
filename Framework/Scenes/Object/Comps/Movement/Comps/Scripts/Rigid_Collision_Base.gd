extends Node
class_name FWCompMovementRigidCollisionBase

var _a_entity: Node
var _a_movement: Node

func _physics_process(p_delta: float) -> void:
	# Handle RigidBody Collisions
	const OWN_MASS: float = 80.0
	for i: int in _a_entity.get_slide_collision_count():
		var slide_coll: RefCounted = _a_entity.get_slide_collision(i)
		var collider: Object = slide_coll.get_collider()
		if _is_instance_rigid_body(collider):
			var movement_velocity: Variant = _a_movement.get_velocity()
			var collider_velocity: Variant = collider.get_linear_velocity()
			var collider_mass: float = collider.get_mass()
			var collider_pos: Variant = collider.get_global_position()
			var push_dir: Variant = -slide_coll.get_normal()
			var velocity_diff: Variant = movement_velocity.dot(push_dir) - collider_velocity.dot(push_dir)
			var mass_ratio: float = min(1.0, OWN_MASS / collider_mass)
			var slide_coll_pos: Variant = slide_coll.get_position()
			var impulse: Variant = push_dir * velocity_diff * mass_ratio * p_delta
			var pos: Variant = slide_coll_pos - collider_pos
			collider.apply_impulse(impulse, pos)

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-2]
	_a_movement = p_entities[-1]

func _is_instance_rigid_body(_p_instance: Node) -> bool:
	return false

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
