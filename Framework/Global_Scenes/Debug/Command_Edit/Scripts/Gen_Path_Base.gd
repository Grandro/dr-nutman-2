extends Node
class_name FWDebugCommandEditGenPathBase

signal last_dir_name_changed(p_dir_name: StringName)
signal path_updated()

const a_SPRITE_PATH: String = "res://Framework/Global_Scenes/Debug/Sprites/Path/%s.png"

@export var _e_point_scene: PackedScene = null

var _a_start: Variant # Vector
var _a_step: Variant # Vector
var _a_path_points: Array = [] # Points of user path
var _a_nav_mesh_path_points: Dictionary = {} # Map nav_mesh_path_point to path_point
var _a_gen_points: Array = [] # Generated points
var _a_sprites: Dictionary = {} # Match point to Sprite instance
var _a_sprite_names: PackedStringArray = PackedStringArray() # Sprite names

func open_load(p_data: Dictionary) -> void:
	_a_path_points = p_data[&"Path_Points"]
	update_path()

func add_path_point(p_path_point: Variant) -> void:
	_a_path_points.push_back(p_path_point)
	update_path()

func remove_path_point(p_path_point: Variant) -> void:
	_a_path_points.erase(p_path_point)
	update_path()

func update_path() -> void:
	_reset()
	
	var world: Variant = _get_world()
	var map_rid: RID = world.get_navigation_map()
	var from_dir_name: StringName = &""
	var path_points_size: int = _a_path_points.size()
	for i: int in path_points_size:
		var path_point: Variant = _a_path_points[i]
		
		var nav_path_points: Array
		if i == path_points_size - 1:
			nav_path_points = _get_nav_path_points(path_point, path_point, map_rid)
		else:
			var next_path_point: Variant = _a_path_points[i + 1]
			nav_path_points = _get_nav_path_points(path_point, next_path_point, map_rid)
		
		var nav_path_points_size: int = nav_path_points.size() - 1
		if i == path_points_size - 1:
			nav_path_points_size += 1
		
		var nav_mesh_path_point: Variant = nav_path_points[0]
		if nav_path_points_size > 0:
			_a_nav_mesh_path_points[nav_mesh_path_point] = path_point
		
		for j: int in nav_path_points_size:
			var nav_path_point: Variant = nav_path_points[j]
			if i == 0 && nav_path_points.size() == 1:
				_instantiate_sprite(nav_path_point, "Start", true)
				continue
			
			if i == path_points_size - 1 && j == nav_path_points.size() - 1:
				_instantiate_sprite(nav_path_point, "End_%s" % from_dir_name, true)
				continue
			
			var next_nav_path_point: Variant = nav_path_points[j + 1]
			var approach: Variant = next_nav_path_point - nav_path_point
			while !_is_approach_at_target(approach):
				var curr_point: Variant = next_nav_path_point - approach
				var dir_name: StringName = _get_next_dir_name(approach)
				approach = _adjust_approach(approach, dir_name)
				
				if _is_approach_at_target(approach):
					last_dir_name_changed.emit(dir_name)
				
				if from_dir_name == &"":
					var sprite_name: String = "Start_%s" % dir_name
					_instantiate_sprite(curr_point, sprite_name, true)
				else:
					var sprite_name: String = "%s_To_%s" % [from_dir_name, dir_name]
					var main: bool = curr_point == nav_mesh_path_point
					_instantiate_sprite(curr_point, sprite_name, main)
				
				from_dir_name = Global.get_opposite_dir_name(dir_name)
	
	path_updated.emit()

func _instantiate_sprite(p_point, p_sprite_name: String, p_main: bool) -> Node:
	var instance: Node = _e_point_scene.instantiate()
	var texture: Texture2D = load(a_SPRITE_PATH % p_sprite_name)
	instance.set_texture(texture)
	
	_a_gen_points.push_back(p_point)
	if p_main:
		_a_sprites[p_point] = instance
		_a_sprite_names.push_back(p_sprite_name)
	add_child(instance)

	return instance

func _reset() -> void:
	for child: Node in get_children():
		child.queue_free()
	_a_nav_mesh_path_points.clear()
	_a_gen_points.clear()
	_a_sprites.clear()
	_a_sprite_names.clear()

func _adjust_approach(_p_approach, _p_dir_name: StringName):
	pass

func set_start(p_start: Variant) -> void:
	_a_start = p_start

func set_step(p_step: Variant) -> void:
	_a_step = p_step

func set_path_points(p_path_points: Array) -> void:
	_a_path_points = p_path_points
	update_path()

func has_path_point(p_path_point: Variant) -> bool:
	return _a_path_points.has(p_path_point)

func get_path_point(p_nav_mesh_point: Variant) -> Variant:
	return _a_nav_mesh_path_points[p_nav_mesh_point]

func get_nav_mesh_path_points() -> Array:
	return _a_nav_mesh_path_points.keys()

func get_sprite_names() -> PackedStringArray:
	return _a_sprite_names

func get_sprite_instance(p_point: Variant) -> Node:
	return _a_sprites[p_point]

func _get_world() -> Variant:
	return null

func _get_nav_path(_p_from, _p_to, _p_map_rid: RID):
	return null

func _get_nav_path_points(p_from: Variant, p_to: Variant, p_map_rid: RID) -> Array:
	var nav_path: Variant = _get_nav_path(p_from, p_to, p_map_rid)
	var nav_path_points: Array = []
	for nav_path_pos: Variant in nav_path:
		var nav_path_point: Variant = Global.pos_to_grid_point(nav_path_pos, _a_step, _a_start)
		if nav_path_points.is_empty() || nav_path_point != nav_path_points[-1]:
			nav_path_points.push_back(nav_path_point)
	
	return nav_path_points

func _get_next_dir_name(_p_approach) -> StringName:
	return &""

func _is_approach_at_target(_p_approach) -> bool:
	return false

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Path_Points"] = _a_path_points
	data[&"Nav_Mesh_Path_Points"] = _a_nav_mesh_path_points
	data[&"Gen_Points"] = _a_gen_points
	
	return data
