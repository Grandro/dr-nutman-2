extends StatsData
class_name EnemyStatsData

@export var _e_EXP: int = -1
@export var _e_loot: Dictionary = {} # [item_key][amount] = amount_in_pool

func get_EXP() -> int:
	return _e_EXP

func get_loot() -> Dictionary:
	return _e_loot
