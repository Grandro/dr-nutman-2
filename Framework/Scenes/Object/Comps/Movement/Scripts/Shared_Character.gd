extends FWCompMovementSharedBase
class_name FWCompMovementSharedCharacter

func physics_process(_p_delta: float) -> void:
	_update_speed()
	
	var comps: Dictionary[StringName, Node] = _a_comph.get_comps()
	_a_velocity = _a_entity.get_init_velocity()
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			_a_velocity += instance.get_velocity_()
	for instance: Node in comps.values():
		if instance.is_in_group(&"Movement"):
			_a_velocity = instance.adjust_velocity_post(_a_velocity)
	
	_a_entity_entity.set_velocity(_a_velocity)
	_a_entity_entity.move_and_slide()
