extends Resource
class_name FWQuestData

@export var _e_key: StringName = &""
@export_enum("Main", "Main_Sub", "Side", "Side_Sub") var _e_type: String = "Main"
@export var _e_location: StringName = &""
@export var _e_name: String = "" # Loc_ID
@export var _e_desc: String = "" # Loc_ID
@export var _e_objectives: Array[FWObjectiveData] = []
@export var _e_rewards: Dictionary[StringName, int] = {} # Match key to amount

func get_key() -> StringName:
	return _e_key

func get_type() -> StringName:
	return _e_type

func get_location() -> StringName:
	return _e_location

func get_name_() -> String:
	return _e_name

func get_desc() -> String:
	return _e_desc

func get_objectives() -> Array[FWObjectiveData]:
	return _e_objectives

func get_rewards() -> Dictionary:
	return _e_rewards
