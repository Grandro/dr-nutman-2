extends Resource
class_name ObjectiveData

@export_enum("Int", "Bool", "Sub_Quest") var _e_type: String = "Int"
@export var _e_desc: StringName = &"" # Loc_ID

func get_type() -> StringName:
	return _e_type

func get_desc() -> StringName:
	return _e_desc
