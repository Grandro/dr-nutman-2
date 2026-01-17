extends SubViewport
class_name VP

@export var _e_sub_world: bool = true # Has own singletons?
@export var _e_game_world: bool = true # Should nodes execute all logic?
@export var _e_resize: bool = true # Resize if root VP resizes?
@export var _e_activate_physics: bool = true # Activate PhysicsServer3D?

#var _a_base_size: Vector2i = Vector2i.ZERO

func _ready() -> void:
	#_a_base_size = get_size()
	#set_size_2d_override(_a_base_size)
	
	var world3D: World3D = find_world_3d()
	var space: RID = world3D.get_space()
	PhysicsServer3D.space_set_active(space, _e_activate_physics)

func resize() -> void:
	pass
	#var root: Window = get_tree().get_root()
	#var root_size: Vector2i = root.get_size()
	#set_size(root_size)
	#set_size_2d_override(_a_base_size)

func is_sub_world() -> bool:
	return _e_sub_world

func is_game_world() -> bool:
	return _e_game_world

func get_resize() -> bool:
	return _e_resize

#func set_base_size(p_base_size: Vector2i) -> void:
#	_a_base_size = p_base_size
