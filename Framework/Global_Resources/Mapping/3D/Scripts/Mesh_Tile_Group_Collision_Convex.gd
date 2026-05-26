@tool
extends FWMeshTileGroupCollision
class_name FWMeshTileGroupCollisionConvex

var _a_base_points: PackedVector3Array

func _ready() -> void:
	var shape: ConvexPolygonShape3D = _a_Collision.get_shape()
	_a_base_points = shape.get_points()
	
	super()

func _update_collision_shape(p_shape: Shape3D, p_size: Vector3) -> void:
	var points: PackedVector3Array = PackedVector3Array()
	for base_point: Vector3 in _a_base_points:
		var point: Vector3 = base_point * p_size
		points.push_back(point)
	
	p_shape.set_points(points)
	_a_Collision.set_shape(p_shape)
