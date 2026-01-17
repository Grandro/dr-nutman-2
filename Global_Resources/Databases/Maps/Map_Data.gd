extends Resource
class_name MapData

@export var _e_path: String = ""
@export var _e_destinations: Dictionary = {}

func get_path_() -> String:
	return _e_path

func get_destinations() -> Dictionary:
	return _e_destinations
