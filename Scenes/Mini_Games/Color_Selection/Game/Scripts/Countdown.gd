extends Control

signal finished()

@onready var _a_Anims = get_node("Anims")

func _ready():
	_a_Anims.animation_finished.connect(_on_anim_finished)

func start():
	_a_Anims.play("Countdown")
	show()

func _on_anim_finished(p_name):
	match p_name:
		"Countdown":
			hide()
			finished.emit()
