extends ExtensionBase
class_name CompNavObstacleShared

func ready() -> void:
	if !_a_entity.get_avoidance_enabled():
		_a_entity.queue_free()
