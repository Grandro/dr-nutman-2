extends Node3D
class_name MapBuffinHouse3Floor3

@onready var _a_Lower_Half: Node3D = get_node("Lower_Half")
@onready var _a_Lower_Half_Below: Node3D = get_node("Lower_Half/Below")
@onready var _a_Same_As: Node3D = get_node("Same_As")

var _a_player_fall_pos: Vector3
var _a_lower_half_visible: bool

func _ready() -> void:
	set_lower_half_visible(false)

func set_player_fall_pos(p_player_fall_pos: Vector3) -> void:
	_a_player_fall_pos = p_player_fall_pos

func get_player_fall_pos() -> Vector3:
	return _a_player_fall_pos

func set_lower_half_visible(p_lower_half_visible: bool) -> void:
	_a_lower_half_visible = p_lower_half_visible
	_a_Lower_Half.set_visible(p_lower_half_visible)
	for child: FWPlaneTileCollision in _a_Lower_Half_Below.get_children():
		child.set_collision_disabled(!p_lower_half_visible)
	_a_Same_As.set_visible(!p_lower_half_visible)

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Player_Fall_Pos"] = _a_player_fall_pos
	data[&"Lower_Half_Visible"] = _a_lower_half_visible
	
	return data

func load_data(p_data: Dictionary) -> void:
	_a_player_fall_pos = p_data[&"Player_Fall_Pos"]
	set_lower_half_visible(p_data[&"Lower_Half_Visible"])
