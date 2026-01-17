extends CompMovementBase3D
class_name CompMovementRigid3D

func integrate_forces(p_state: PhysicsDirectBodyState3D) -> void:
	_a_shared.integrate_forces(p_state)
