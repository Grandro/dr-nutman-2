extends Node3D
class_name SVEncounterCommandCircleEntry

@onready var _a_Image: Sprite3D = get_node("Image")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")

var _a_command: StringName

func play_anim(p_name: StringName) -> void:
	_a_Anims.play(p_name)

func stop_anim(p_keep_state: bool = false) -> void:
	_a_Anims.stop(p_keep_state)

func set_image_texture(p_texture: Texture2D) -> void:
	_a_Image.set_texture(p_texture)

func set_command(p_command: StringName) -> void:
	_a_command = p_command

func get_command() -> StringName:
	return _a_command
