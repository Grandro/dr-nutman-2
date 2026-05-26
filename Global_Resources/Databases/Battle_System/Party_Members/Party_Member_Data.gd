extends Resource
class_name PartyMemberData

@export var _e_stats: FWStatsData = null
@export var _e_actions: Dictionary = {&"Commands": {}, &"Specials": {}}

func get_stats() -> FWStatsData:
	return _e_stats

func get_commands() -> Dictionary:
	return _e_actions[&"Commands"]

func get_specials() -> Dictionary:
	return _e_actions[&"Specials"]

func get_exp_till_next_lvl(p_lvl: int) -> int:
	return int(5 * pow(p_lvl, 1.5))
