extends Resource
class_name FWMapData

@export var _e_uid: String = ""
@export var _e_destinations: Dictionary = {}

func get_uid() -> String:
	return _e_uid

func get_destinations() -> Dictionary:
	return _e_destinations
