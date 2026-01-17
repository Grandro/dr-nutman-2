extends CompMovementRigidCollisionBase
class_name CompMovementRigidCollision2D

func _is_instance_rigid_body(p_instance: Node) -> bool:
	return p_instance is RigidBody2D
