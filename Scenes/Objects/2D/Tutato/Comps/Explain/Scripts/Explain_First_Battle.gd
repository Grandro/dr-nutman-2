extends ObjectTutatoCompExplainBase2D
class_name ObjectTutatoCompExplainFirstBattle2D

@onready var _a_Stats_Detail: VBoxContainer = get_node("Control/Parts/Stats_Detail")

func _ready() -> void:
	super()
	for child: Container in _a_Stats_Detail.get_children():
		child.hide()

func open() -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(&"Tutato_Explain", &"First_Battle_Intro", &"Main", &"Global")

func set_stats_detail_part_visible(p_key: String, p_visible: bool) -> void:
	var instance: Container = _a_Stats_Detail.get_node(p_key)
	instance.set_visible(p_visible)
