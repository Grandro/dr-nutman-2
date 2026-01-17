extends StatsDisplayBase
class_name StatsDisplayBattle

func open(p_party_members: Dictionary[StringName, SVPartyMember]) -> void:
	for key: StringName in p_party_members:
		var instance: SVPartyMember = p_party_members[key]
		var stats_comp: CompSVStats = instance.comph().get_comp("Stats")
		stats_comp.stat_changed.connect(_on_pm_stat_changed.bind(key))
		var entry_scene: PackedScene = load(_a_ENTRY_SCENE_PATH % key)
		var entry_instance: StatsDisplayEntryBase = entry_scene.instantiate()
		for stat: StringName in _e_visible_stats:
			var value: int = _get_pm_stat(instance, stat)
			_set_entry_stat(entry_instance, stat, value, false)
		
		_a_entries[key] = entry_instance
		_a_Entries.add_child(entry_instance)

func _get_pm_stat(p_instance: SVPartyMember, p_stat: StringName) -> int:
	if p_stat.begins_with("Max_"):
		var stat: StringName = p_stat.trim_prefix("Max_")
		return p_instance.comph().call_comp("Stats", &"get_max_stat", [stat])
	else:
		return p_instance.comph().call_comp("Stats", &"get_curr_stat", [p_stat])

func _on_pm_stat_changed(p_stat: StringName, p_value: int, p_key: StringName) -> void:
	if !_e_visible_stats.has(p_stat):
		return
	
	var instance: StatsDisplayEntryBase = _a_entries[p_key]
	_set_entry_stat(instance, p_stat, p_value, true)
