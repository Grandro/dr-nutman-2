extends VBoxContainer
class_name MainMenuSubMenuPartyStatusEquipableCharacter

const _a_CHARACTER_SCENE_PATH: String = "res://Scenes/Characters/%s/%s.tscn"

@onready var _a_VP: VP = get_node("Panel/Margin/VP")

var _a_character: Node3DObject = null # Character instance

func update_character(p_key: String) -> void:
	for child: Node3DObject in _a_VP.get_children():
		child.queue_free()
	
	var scene: PackedScene = load(_a_CHARACTER_SCENE_PATH % [p_key, p_key])
	var instance: Node3DObject = scene.instantiate()
	_a_VP.add_child(instance)
	_a_character = instance

func get_character() -> Node3DObject:
	return _a_character

func _on_Arrow_pressed(p_rotate_degrees: float) -> void:
	var old_dir: StringName = _a_character.comph().call_comp("Movement", &"get_dir")
	var new_dir: StringName = Global.get_dir_rotated(old_dir, p_rotate_degrees)
	_a_character.comph().call_comp("Movement", &"set_dir", [new_dir])
	_a_character.comph().call_comp("Anims", &"update_anim")
