extends "res://Scenes/Objects/2D/Tutato/Comps/Explain/Scripts/Explain_Base.gd"

@onready var _a_Stats_Detail = get_node("Control/Parts/Stats_Detail")

func _ready():
	super()
	for child in _a_Stats_Detail.get_children():
		child.hide()

func open():
	var cutscene_system_si = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene("Tutato_Explain", "First_Battle_Intro", "Main", "Global")

func set_stats_detail_part_visible(p_key, p_visible):
	var instance = _a_Stats_Detail.get_node(p_key)
	instance.set_visible(p_visible)
