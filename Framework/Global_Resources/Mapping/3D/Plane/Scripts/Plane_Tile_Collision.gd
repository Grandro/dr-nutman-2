@tool
extends FWPlaneTile
class_name FWPlaneTileCollision

@onready var _a_Collision: CollisionShape3D = get_node("Static/Collision")

func _update() -> void:
	if !is_node_ready():
		return
	
	super()
	
	var shape: BoxShape3D = _a_Collision.get_shape()
	var shape_dup: BoxShape3D = shape.duplicate()
	var size: Vector3 = _e_size * _e_base_size
	shape_dup.size.x = size.x
	shape_dup.size.z = size.z
	_a_Collision.set_shape(shape_dup)

func set_collision_disabled(p_disabled: bool) -> void:
	_a_Collision.set_disabled(p_disabled)
