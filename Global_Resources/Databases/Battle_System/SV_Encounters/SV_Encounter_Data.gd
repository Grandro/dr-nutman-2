extends Resource
class_name SVEncounterData

@export var _e_path: String = ""
@export var _e_special: bool = false

func get_path_() -> String:
	return _e_path

func get_special() -> bool:
	return _e_special
