extends Button
class_name DebugCommandsListEntry

@export var _e_command: StringName = &""
@export var _e_scene_paths: Dictionary[StringName, String] = {&"2D": "", &"3D": ""}

func get_command() -> StringName:
	return _e_command

func get_scene_paths() -> Dictionary[StringName, String]:
	return _e_scene_paths
