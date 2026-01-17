extends CompMovementSharedBase
class_name CompMovementSharedCharacter

func physics_process(_p_delta: float) -> void:
	_update_speed()
	
	_a_velocity = _a_entity.get_init_velocity()
	for child: Node in _a_entity.get_children():
		_a_velocity += child.get_velocity_()
	for child: Node in _a_entity.get_children():
		_a_velocity = child.adjust_velocity_post(_a_velocity)
	
	_a_entity_entity.set_velocity(_a_velocity)
	_a_entity_entity.move_and_slide()
