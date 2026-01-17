extends StatsDisplayBase
class_name StatsDisplayGlobal

func _ready() -> void:
	super()
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.pm_stat_changed.connect(_on_pm_stat_changed)
	
	_instantiate_entries()

func _instantiate_entries() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var party_members: Dictionary = global_si.get_party_members_active()
	for key: StringName in party_members:
		var args: Dictionary = party_members[key]
		var stats: Dictionary[String, int] = args[&"Stats"]
		var scene: PackedScene = load(_a_ENTRY_SCENE_PATH % key)
		var instance: StatsDisplayEntryBase = scene.instantiate()
		for stat: StringName in _e_visible_stats:
			var value: int = stats[stat]
			_set_entry_stat(instance, stat, value, false)
		
		_a_entries[key] = instance
		_a_Entries.add_child(instance)

func _on_pm_stat_changed(p_key: StringName, p_stat: StringName, p_value: int) -> void:
	if !_e_visible_stats.has(p_stat):
		return
	
	var instance: StatsDisplayEntryBase = _a_entries[p_key]
	_set_entry_stat(instance, p_stat, p_value, true)
