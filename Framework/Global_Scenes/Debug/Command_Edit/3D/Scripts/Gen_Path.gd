extends FWDebugCommandEditGenPathBase
class_name FWDebugCommandEditGenPath3D

func _instantiate_sprite(p_point: Vector3, p_sprite_name: String, p_main: bool) -> Node:
	var instance: Sprite3D = super(p_point, p_sprite_name, p_main)
	var half_offset: Vector3 = Vector3(_a_step.x / 2.0, 0, _a_step.z / 2.0)
	var pos: Vector3 = _a_start + (p_point * _a_step) + half_offset
	var scale_: Vector3 = _a_step
	instance.set_position(Vector3(pos.x, pos.y + 0.01, pos.z))
	instance.set_scale(Vector3(scale_.x, scale_.z, 1.0))

	return instance

func _adjust_approach(p_approach: Vector3, p_dir: StringName) -> Vector3:
	match p_dir:
		&"Right": p_approach.x -= 1
		&"Left": p_approach.x += 1
		&"Down": p_approach.z -= 1
		&"Up": p_approach.z += 1
	
	return p_approach

func _get_world() -> World3D:
	var vp: Viewport = get_viewport()
	var world_3d: World3D = vp.find_world_3d()
	
	return world_3d

func _get_nav_path(p_from: Vector3, p_to: Vector3, p_map_rid: RID) -> PackedVector3Array:
	var from_pos: Vector3 = Global.grid_point_to_pos(p_from, _a_step, _a_start)
	var to_pos: Vector3 = Global.grid_point_to_pos(p_to, _a_step, _a_start)
	var nav_path: PackedVector3Array = NavigationServer3D.map_get_path(p_map_rid, from_pos, to_pos, true)
	
	return nav_path

func _get_next_dir(p_approach: Vector3) -> StringName:
	var dir: StringName
	if abs(p_approach.x) > abs(p_approach.z):
		if p_approach.x > 0:
			dir = &"Right"
		else:
			dir = &"Left"
	else:
		if p_approach.z > 0:
			dir = &"Down"
		else:
			dir = &"Up"
	
	return dir

func _is_approach_at_target(p_approach: Vector3) -> bool:
	return p_approach.x == 0.0 && p_approach.z == 0.0
