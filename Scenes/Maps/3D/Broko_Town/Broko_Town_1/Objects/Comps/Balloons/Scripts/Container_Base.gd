extends Node3D
class_name CompBalloonsContainerBase

@onready var _a_Joint: PinJoint3D = get_node("Joint")
@onready var _a_Balloon: RigidBody3D = get_node("Balloon")
@onready var _a_Balloon_Sprite: Sprite3D = get_node("Balloon/Sprite")
@onready var _a_Balloon_Mark: Marker3D = get_node("Balloon/Mark")

var _a_manually_added: bool = false

func set_joint_node_a(p_path: NodePath) -> void:
	_a_Joint.set_node_a(p_path)

func set_balloon_modulate(p_modulate: Color) -> void:
	_a_Balloon_Sprite.set_modulate(p_modulate)

func get_global_balloon_mark_position() -> Vector3:
	return _a_Balloon_Mark.get_global_position()

func set_manually_added(p_manually_added: bool) -> void:
	_a_manually_added = p_manually_added

func get_manually_added() -> bool:
	return _a_manually_added

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Balloon_Modulate"] = _a_Balloon_Sprite.get_modulate()
	data[&"Manually_Added"] = _a_manually_added
	
	return data
