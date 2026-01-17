extends Control
class_name StatsDisplayEntryBase

@onready var _a_VBox: VBoxContainer = get_node("VBox")
@onready var _a_Stats: VBoxContainer = get_node("VBox/Margin/Stats/VBox")
@onready var _a_Anims: AnimationPlayer = get_node("Anims")

var _a_stats: Dictionary[StringName, StatsDisplayEntryStatEntry] = {} # Match key to instance
var _a_folded: bool = true

func _ready() -> void:
	_a_VBox.gui_input.connect(_on_VBox_gui_input)
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	for child: StatsDisplayEntryStatEntry in _a_Stats.get_children():
		var key: StringName = child.get_key()
		_a_stats[key] = child

func set_stat_value(p_stat: StringName, p_value: int, p_anim: bool) -> void:
	var instance: StatsDisplayEntryStatEntry = _a_stats[p_stat]
	instance.set_value(p_value, p_anim)

func set_stat_max_value(p_stat: StringName, p_max_value: int) -> void:
	var instance: StatsDisplayEntryStatEntry = _a_stats[p_stat]
	instance.set_max_value(p_max_value)

func _on_VBox_gui_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Mouse_Left"):
		if _a_folded:
			_a_Anims.play(&"Unfold")
		else:
			_a_Anims.play(&"Fold")

func _on_anim_finished(p_name: StringName) -> void:
	match p_name:
		&"Fold": _a_folded = true
		&"Unfold": _a_folded = false
