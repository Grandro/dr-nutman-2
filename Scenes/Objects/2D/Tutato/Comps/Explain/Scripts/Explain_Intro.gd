extends ObjectTutatoCompExplainBase2D
class_name ObjectTutatoCompExplainIntro2D

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func _ready() -> void:
	super()
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func open() -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Tutato_Explain", &"Intro", &"Main", &"Global")

func close() -> void:
	_a_Anims.play(&"Fade_Out")

func _on_Anims_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fade_Out":
			completed.emit()
			hide()
			_a_Background.set_color(Color.WHITE)
