@tool
extends FWMeshTileGroupCollision
class_name FWMeshTileGroupCollisionBox

func _update_collision_shape(p_shape: Shape3D, p_size: Vector3) -> void:
	p_shape.set_size(p_size)
	_a_Collision.set_shape(p_shape)
