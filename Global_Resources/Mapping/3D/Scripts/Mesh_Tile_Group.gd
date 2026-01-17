@tool
extends Node3D
class_name MeshTileGroup

@export var _e_offset: Vector3 = Vector3.ZERO:
	set(p_value):
		_e_offset = p_value
		_update()

@export var _e_size: Vector3 = Vector3.ONE:
	set(p_value):
		_e_size = p_value
		_update()

@onready var _a_Tiles: Node3D = get_node("Tiles")

func _ready() -> void:
	_update()

func _update() -> void:
	if !is_node_ready():
		return
	
	for child: MeshTile in _a_Tiles.get_children():
		child.set_offset(_e_offset)
		child.set_size(_e_size)
