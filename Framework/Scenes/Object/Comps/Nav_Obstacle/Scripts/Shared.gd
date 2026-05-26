extends FWExtensionBase
class_name FWCompNavObstacleShared

func ready() -> void:
	if !_a_entity.get_avoidance_enabled():
		_a_entity.queue_free()
