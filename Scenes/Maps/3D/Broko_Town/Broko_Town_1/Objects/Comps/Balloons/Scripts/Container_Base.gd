extends Node3D

@onready var _a_Joint = get_node("Joint")
@onready var _a_Balloon = get_node("Balloon")
@onready var _a_Balloon_Sprite = get_node("Balloon/Sprite")
@onready var _a_Balloon_Mark = get_node("Balloon/Mark")

var _a_manually_added = false

func set_joint_node_a(p_path):
	_a_Joint.set_node_a(p_path)

func set_balloon_modulate(p_modulate):
	_a_Balloon_Sprite.set_modulate(p_modulate)

func get_global_balloon_mark_position():
	return _a_Balloon_Mark.get_global_position()

func set_manually_added(p_manually_added):
	_a_manually_added = p_manually_added

func get_manually_added():
	return _a_manually_added

func get_save_data():
	var data = {}
	data["Balloon_Modulate"] = _a_Balloon_Sprite.get_modulate()
	data["Manually_Added"] = _a_manually_added
	
	return data
