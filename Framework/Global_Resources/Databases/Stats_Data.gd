extends Resource
class_name FWStatsData

@export var _e_stats: Dictionary[StringName, int] = {} # Match stat name to value

func get_stat(p_stat: StringName) -> int:
	return _e_stats[p_stat]
