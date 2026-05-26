extends FWCompMovementRigidCollisionBase
class_name FWCompMovementRigidCollision2D

func _is_instance_rigid_body(p_instance: Node) -> bool:
	return p_instance is RigidBody2D
