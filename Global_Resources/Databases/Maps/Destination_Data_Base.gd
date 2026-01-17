extends Resource
class_name DestinationDataBase

@export_enum("Down", "Left", "Right", "Up") var _e_dir: String = "Down"
@export var _e_camera_limit_active: bool = false

func get_dir() -> StringName:
	return _e_dir

func is_camera_limit_active() -> bool:
	return _e_camera_limit_active
