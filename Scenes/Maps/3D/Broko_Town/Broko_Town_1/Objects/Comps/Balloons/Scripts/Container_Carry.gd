extends CompBalloonsContainerBase
class_name CompBalloonsContainerCarry

var _a_entity: Node

func _physics_process(p_delta: float) -> void:
	var entity_velocity: Vector3 = _a_entity.get_real_velocity()
	entity_velocity = entity_velocity.normalized()
	
	var impulse: Vector3 = -entity_velocity * p_delta * 0.2
	_a_Balloon.apply_central_impulse(impulse)

func set_entity(p_entity: Node) -> void:
	_a_entity = p_entity
