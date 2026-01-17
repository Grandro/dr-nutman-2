extends Resource
class_name ActionData

const _a_NAME_LOC_ID: String = "SV_ACTIONS_%s_NAME"
const _a_DESC_LOC_ID: String = "SV_ACTIONS_%s_DESC"

@export var _e_key: StringName = &""
@export_enum("None", "Ally", "Enemy") var _e_target_type: String = "None"
@export var _e_target_amount: int = -1
@export var _e_SP_cost: int = -1

func get_key() -> StringName:
	return _e_key

func get_name_() -> String:
	var key_upper: StringName = _e_key.to_upper()
	var name_: String = tr(_a_NAME_LOC_ID % key_upper)
	
	return name_

func get_desc() -> String:
	var key_upper: StringName = _e_key.to_upper()
	var desc: String = tr(_a_DESC_LOC_ID % key_upper)
	
	return desc

func get_target_type() -> StringName:
	return _e_target_type

func get_target_amount() -> int:
	return _e_target_amount

func get_SP_cost() -> int:
	return _e_SP_cost
