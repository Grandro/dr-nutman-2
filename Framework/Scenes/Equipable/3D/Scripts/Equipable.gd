extends Sprite3D
class_name FWEquipable3D

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

func play_anim(p_name: StringName, p_speed: float, p_backwards: bool) -> void:
	_a_Anims.play(p_name, -1.0, p_speed, p_backwards)

func seek_anim(p_seconds: float, p_update: bool) -> void:
	_a_Anims.seek(p_seconds, p_update)

func stop_anim(p_keep_state: bool) -> void:
	_a_Anims.stop(p_keep_state)
