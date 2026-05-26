extends Resource
class_name SVEncounterData

@export var _e_uid: String = ""
@export var _e_special: bool = false

func get_uid() -> String:
	return _e_uid

func get_special() -> bool:
	return _e_special
