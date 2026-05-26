extends Resource
class_name FWObjectiveData

@export var _e_type: StringName = &"Int"
@export var _e_desc: StringName = &"" # Loc_ID

func get_type() -> StringName:
	return _e_type

func get_desc() -> StringName:
	return _e_desc
