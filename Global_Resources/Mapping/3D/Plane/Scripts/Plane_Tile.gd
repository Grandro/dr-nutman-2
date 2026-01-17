@tool
extends MeshTile
class_name PlaneTile

func _update() -> void:
	if !is_node_ready():
		return
	if mesh == null:
		return
	
	super()
	
	var size: Vector3 = _e_size * _e_base_size
	var snapped_rotation: Vector3 = rotation.snappedf(deg_to_rad(90.0))
	var basis_: Basis = Basis.from_euler(snapped_rotation)
	size = (basis_.inverse() * size).abs()
	mesh.set_size(Vector2(size.x, size.z))
