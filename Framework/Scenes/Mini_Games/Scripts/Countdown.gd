extends Control
class_name FWMiniGameCountdown

signal finished()

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func _ready() -> void:
	_a_Anims.animation_finished.connect(_on_anim_finished)

func start() -> void:
	_a_Anims.play(&"Countdown")
	show()

func _on_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Countdown":
			hide()
			finished.emit()
