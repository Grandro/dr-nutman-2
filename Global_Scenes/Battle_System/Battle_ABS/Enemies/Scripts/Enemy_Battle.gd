extends "res://Global_Scenes/Battle_System/Battle_ABS/Scripts/Character_Battle.gd"
class_name ABSEnemy

@onready var _a_HUD = get_node("HUD")

func damage(p_dmg):
	set_HP(_a_HP - p_dmg)
	_a_HUD.set_HP(_a_HP)

func set_hud_data(p_max_HP, p_max_SP):
	_a_HUD.set_data(p_max_HP, p_max_SP)

func _on_SP_Regen_timeout():
	super()
	_a_HUD.set_SP(_a_SP)
