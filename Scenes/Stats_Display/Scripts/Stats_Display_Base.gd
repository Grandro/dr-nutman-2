extends MarginContainer
class_name StatsDisplayBase

@export var _e_visible_stats: Array[StringName] = [&"HP", &"Max_HP", &"SP", &"Max_SP", &"ATK", &"MAG", &"DEF", &"SPEED", &"LUCK"]

const _a_ENTRY_SCENE_PATH: String = "res://Scenes/Stats_Display/Entries/%s.tscn"

@onready var _a_Entries: HBoxContainer = get_node("Entries")

var _a_entries: Dictionary[StringName, StatsDisplayEntryBase] = {} # Match key to instance

func _ready() -> void:
	for child: StatsDisplayEntryBase in _a_Entries.get_children():
		child.queue_free()

func _set_entry_stat(p_instance: StatsDisplayEntryBase, p_stat: StringName, p_value: int, p_anim: bool) -> void:
	if p_stat.begins_with("Max_"):
		var stat: StringName = p_stat.trim_prefix("Max_")
		p_instance.set_stat_max_value.call_deferred(stat, p_value)
	else:
		p_instance.set_stat_value.call_deferred(p_stat, p_value, p_anim)
