extends FWCompMovementSharedBase
class_name FWCompMovementSharedRigid

func integrate_forces(p_state: Object) -> void:
	_update_speed()
	
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	var linear_velocity: Variant = p_state.get_linear_velocity()
	_a_velocity = linear_velocity
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			_a_velocity += instance.get_velocity_()
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			_a_velocity = instance.adjust_velocity_post(_a_velocity)
	
	var central_force: Variant = _a_velocity - linear_velocity
	p_state.apply_central_force(central_force * 0.2)
