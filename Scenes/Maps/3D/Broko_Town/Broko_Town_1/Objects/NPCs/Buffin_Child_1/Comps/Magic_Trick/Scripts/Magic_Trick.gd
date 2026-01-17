extends CanvasLayer
class_name CompMagicTrick

@onready var _a_Anims: AnimationPlayer = get_node("Control/Anim/Anims")

func _ready() -> void:
	_a_Anims.animation_finished.connect(_on_anim_finished)
	hide()

func init(_p_entity: Character3DObject) -> void:
	pass

func play_anim(p_name: StringName) -> void:
	_a_Anims.play(p_name)

func queue_anim(p_name: StringName) -> void:
	_a_Anims.queue(p_name)

func stop_anim() -> void:
	_a_Anims.stop()

func set_anim_loop_mode(p_name: StringName, p_loop_mode: Animation.LoopMode) -> void:
	var anim: Animation = _a_Anims.get_animation(p_name)
	anim.set_loop_mode(p_loop_mode)

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_anim_finished(p_name: StringName) -> void:
	if p_name == &"Swallow":
		play_anim(&"Sparkle")
