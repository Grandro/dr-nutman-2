extends TextureButton
class_name FWVirtualKeyboardKey

const _a_KEY_PATH: String = "res://Global_Resources/Sprites/Keys/%s.png"

@onready var _a_Anims: AnimationPlayer = get_node("Anims")

var _a_char_idx: int
var _a_button_down: bool

func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func set_key_texture(p_key: String) -> void:
	var texture: Texture2D = load(_a_KEY_PATH % p_key)
	set_texture_normal(texture)
	set_texture_focused(texture)

func set_char_idx(p_char_idx: int) -> void:
	_a_char_idx = p_char_idx

func get_char_idx() -> int:
	return _a_char_idx

func _on_button_down() -> void:
	_a_button_down = true
	_a_Anims.play(&"Scale_Down")

func _on_button_up() -> void:
	if _a_button_down:
		_a_button_down = false
		_a_Anims.play(&"Scale_Up")
