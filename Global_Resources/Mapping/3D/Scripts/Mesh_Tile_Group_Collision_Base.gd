@tool
extends MeshTileGroup
class_name MeshTileGroupCollision

@export var _e_coll_base_size: Vector3 = Vector3.ONE:
	set(p_value):
		_e_coll_base_size = p_value
		_update()

@onready var _a_Collision: CollisionShape3D = get_node("Static/Collision")

func _update() -> void:
	if !is_node_ready():
		return
	
	super()
	
	var shape: Shape3D = _a_Collision.get_shape()
	if shape == null:
		return
	
	var shape_dup: Shape3D = shape.duplicate()
	var size: Vector3 = _e_size * _e_coll_base_size
	_update_collision_shape(shape_dup, size)

func _update_collision_shape(_p_shape: Shape3D, _p_size: Vector3) -> void:
	pass
