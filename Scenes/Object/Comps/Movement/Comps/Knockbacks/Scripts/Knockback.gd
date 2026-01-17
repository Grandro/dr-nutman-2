extends Timer
class_name CompMovementKnockbacksKnockback

var _a_init_velocity: Variant # Vector

func _ready() -> void:
	timeout.connect(_on_timeout)

func set_init_velocity(p_init_velocity: Variant) -> void:
	_a_init_velocity = p_init_velocity

func get_init_velocity() -> Variant:
	return _a_init_velocity

func _on_timeout() -> void:
	queue_free()
