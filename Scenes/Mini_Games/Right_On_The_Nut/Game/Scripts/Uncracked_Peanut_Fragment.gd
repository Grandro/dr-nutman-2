extends RigidBody2D
class_name MiniGameRightOnTheNutUncrackedPeanutFragment

const _a_TEXTURE_PATH: String = "res://Scenes/Mini_Games/Right_On_The_Nut/Game/Sprites/Uncracked_Peanut_Fragment_%s.png"

@onready var _a_Sprite: Sprite2D = get_node("Sprite")

func _ready() -> void:
	var texture_idx: int = randi() % 3 + 1
	var texture_path: String = _a_TEXTURE_PATH % texture_idx
	var texture: Texture2D = load(texture_path)
	_a_Sprite.set_texture(texture)
