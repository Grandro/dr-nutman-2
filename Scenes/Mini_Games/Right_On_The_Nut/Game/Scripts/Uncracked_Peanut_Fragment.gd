extends RigidBody2D

const _a_TEXTURE_PATH = "res://Scenes/Mini_Games/Right_On_The_Nut/Game/Sprites/Uncracked_Peanut_Fragment_%s.png"

@onready var _a_Sprite = get_node("Sprite")

func _ready():
	var texture_idx = randi() % 3 + 1
	var texture_path = _a_TEXTURE_PATH % texture_idx
	var texture = load(texture_path)
	_a_Sprite.set_texture(texture)
