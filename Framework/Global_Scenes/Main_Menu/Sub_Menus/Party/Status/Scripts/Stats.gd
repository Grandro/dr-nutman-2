extends VBoxContainer
class_name MainMenuSubMenuPartyStatusStats

var _a_key: StringName = &"" # Party_Member key
var _a_stats: Dictionary[StringName, MainMenuSubMenuPartyStatusStatEntry] = {} # Match key to instance

func _ready() -> void:
	for child: MainMenuSubMenuPartyStatusStatEntry in get_children():
		var key: StringName = child.get_key()
		var max_key: StringName = child.get_max_key()
		_a_stats[key] = child
		if max_key != &"":
			_a_stats[max_key] = child
	
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.pm_stat_changed.connect(_on_Global_pm_stat_changed)

func open(p_key: StringName, p_stats: Dictionary[StringName, int]) -> void:
	_a_key = p_key
	
	for stat: StringName in p_stats:
		var instance: MainMenuSubMenuPartyStatusStatEntry = _a_stats[stat]
		var value: int = p_stats[stat]
		instance.set_curr_value(value)
		
		var max_key: StringName = instance.get_max_key()
		if max_key != &"":
			var max_value: int = p_stats[max_key]
			instance.set_max_value(max_value)
		else:
			instance.hide_max_value()

func _on_Global_pm_stat_changed(p_key: StringName, p_stat: StringName, p_value: int) -> void:
	if p_key != _a_key:
		return
	
	var instance: MainMenuSubMenuPartyStatusStatEntry = _a_stats[p_stat]
	if p_stat.begins_with("Max"):
		instance.set_max_value(p_value)
	else:
		instance.set_curr_value(p_value)
