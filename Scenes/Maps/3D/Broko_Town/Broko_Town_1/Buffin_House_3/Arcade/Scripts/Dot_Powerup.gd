extends ArcadeDot
class_name ArcadeDotPowerup

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func start_blink() -> void:
	_a_Anims.play(&"Blink")

func stop_blink() -> void:
	_a_Anims.stop()
