extends "res://Scenes/Objects/2D/Tutato/Comps/Explain/Scripts/Explain_Base.gd"

@onready var _a_Anims = get_node("Anims")

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func open():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Tutato_Explain", "Intro", "Main", "Global")

func close():
	_a_Anims.play("Fade_Out")

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Fade_Out":
			completed.emit()
			hide()
			_a_Background.set_color(Color.WHITE)
