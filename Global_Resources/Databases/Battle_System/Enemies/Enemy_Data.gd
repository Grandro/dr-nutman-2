extends Resource
class_name EnemyData

const _a_NAME_LOC_ID: String = "ENEMY_%s_NAME"
const _a_DESC_LOC_ID: String = "ENEMY_%s_DESC"

@export var _e_key: StringName = &""
@export var _e_stats: EnemyStatsData = null
@export var _e_actions: Dictionary = {&"Commands": [], &"Specials": []}

func get_name_() -> String:
	var key_upper: StringName = _e_key.to_upper()
	var name_: String = tr(_a_NAME_LOC_ID % key_upper)
	
	return name_

func get_desc() -> String:
	var key_upper: StringName = _e_key.to_upper()
	var desc: String = tr(_a_DESC_LOC_ID % key_upper)
	
	return desc

func get_stats() -> EnemyStatsData:
	return _e_stats

func get_actions() -> Dictionary:
	return _e_actions
