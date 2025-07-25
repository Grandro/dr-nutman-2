extends CanvasLayer

@onready var _a_Anims = get_node("Control/Anim/Anims")

func _ready():
	_a_Anims.animation_finished.connect(_on_anim_finished)
	hide()

func init(_p_entity):
	pass

func play_anim(p_anim_name):
	_a_Anims.play(p_anim_name)

func queue_anim(p_anim_name):
	_a_Anims.queue(p_anim_name)

func stop_anim():
	_a_Anims.stop()

func set_anim_loop_mode(p_anim_name, p_loop_mode):
	var anim = _a_Anims.get_animation(p_anim_name)
	anim.set_loop_mode(p_loop_mode)

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_anim_finished(p_anim_name):
	if p_anim_name == "Swallow":
		play_anim("Sparkle")
