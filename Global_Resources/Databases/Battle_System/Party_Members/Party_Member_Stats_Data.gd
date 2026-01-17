extends StatsData
class_name PartyMemberStatsData

@export var _e_max_HP: int = -1
@export var _e_max_SP: int = -1

func get_max_HP() -> int:
	return _e_max_HP

func get_max_SP() -> int:
	return _e_max_SP
