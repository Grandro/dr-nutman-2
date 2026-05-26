extends Resource
class_name FWCompData

@export var _e_scene: PackedScene = null
@export var _e_group: StringName = &""

func get_scene() -> PackedScene:
	return _e_scene

func get_group() -> StringName:
	return _e_group
