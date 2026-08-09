extends Resource
class_name FWDestinationDataBase

@export var _e_dir_name: StringName = &"Down"
@export var _e_camera_limit_active: bool = false

func get_dir_name() -> StringName:
	return _e_dir_name

func is_camera_limit_active() -> bool:
	return _e_camera_limit_active
