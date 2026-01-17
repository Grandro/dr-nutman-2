extends DebugCommandEditGenPathBase
class_name DebugCommandEditGenPath2D

func _instantiate_sprite(p_point: Vector2, p_sprite_name: String, p_main: bool) -> Node:
	var instance: Sprite2D = super(p_point, p_sprite_name, p_main)
	var half_offset: Vector2 = _a_step / 2.0
	var pos: Vector2 = _a_start + (p_point * _a_step) + half_offset
	var scale_: Vector2 = _a_step / 50.0
	instance.set_position(pos)
	instance.set_scale(scale_)

	return instance

func _adjust_approach(p_approach: Vector2, p_dir: StringName) -> Vector2:
	match p_dir:
		&"Right": p_approach.x -= 1
		&"Left": p_approach.x += 1
		&"Down": p_approach.y -= 1
		&"Up": p_approach.y += 1
	
	return p_approach

func _get_world() -> World2D:
	var vp: Viewport = get_viewport()
	var world_2d: World2D = vp.find_world_2d()
	
	return world_2d

func _get_nav_path(p_from: Vector2, p_to: Vector2, p_map_rid: RID):
	var from_pos: Vector2 = Global.grid_point_to_pos(p_from, _a_step, _a_start)
	var to_pos: Vector2 = Global.grid_point_to_pos(p_to, _a_step, _a_start)
	var nav_path: PackedVector2Array = NavigationServer2D.map_get_path(p_map_rid, from_pos, to_pos, true)
	
	return nav_path

func _get_next_dir(p_approach: Vector2) -> StringName:
	var dir: StringName
	if abs(p_approach.x) > abs(p_approach.y):
		if p_approach.x > 0:
			dir = &"Right"
		else:
			dir = &"Left"
	else:
		if p_approach.y > 0:
			dir = &"Down"
		else:
			dir = &"Up"
	
	return dir

func _is_approach_at_target(p_approach: Vector2) -> bool:
	return p_approach == Vector2.ZERO
