extends CompMovementJumpBase
class_name CompMovementJump2D

func _init() -> void:
	_a_gravity_vec = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
	_a_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	_a_velocity = Vector2.ZERO

func _ready() -> void:
	set_physics_process(false)
