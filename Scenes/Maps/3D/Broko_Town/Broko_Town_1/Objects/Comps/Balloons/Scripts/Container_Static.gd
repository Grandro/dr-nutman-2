extends CompBalloonsContainerBase
class_name CompBalloonsContainerStatic

@onready var _a_Timer: Timer = get_node("Timer")

func _ready() -> void:
	_a_Timer.timeout.connect(_on_Timer_timeout)
	
	_apply_balloon_impulse()
	var time: float = randf_range(4.0, 8.0)
	_a_Timer.start(time)

func _apply_balloon_impulse() -> void:
	var impulse_x: float = randf_range(-0.1, 0.1)
	var impulse_z: float = randf_range(-0.1, 0.1)
	_a_Balloon.apply_central_impulse(Vector3(impulse_x, 0.0, impulse_z))

func _on_Timer_timeout() -> void:
	_apply_balloon_impulse()
	var time: float = randf_range(4, 8)
	_a_Timer.start(time)
