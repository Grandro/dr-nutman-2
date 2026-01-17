extends CanvasLayer
class_name SVEncounterIndicatorSpecialsMenu

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func _ready() -> void:
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	hide()

func open() -> void:
	_a_Anims.play(&"Fade_In")
	show()

func close() -> void:
	_a_Anims.play(&"Fade_Out")

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_Out":
			hide()
