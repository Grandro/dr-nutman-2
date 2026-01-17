extends CompMovementRigidCollisionBase
class_name CompMovementRigidCollision3D

func _is_instance_rigid_body(p_instance: Node) -> bool:
	return p_instance is RigidBody3D
