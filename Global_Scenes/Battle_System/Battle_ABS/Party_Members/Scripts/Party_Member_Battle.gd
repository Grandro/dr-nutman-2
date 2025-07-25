extends "res://Global_Scenes/Battle_System/Battle_ABS/Scripts/Character_Battle.gd"

var _a_hud_entry = null

func damage(p_dmg):
	set_HP(_a_HP - p_dmg)
	_a_hud_entry.set_HP(_a_HP)

func set_hud_entry(p_instance):
	_a_hud_entry = p_instance

func _on_SP_Regen_timeout():
	super()
	_a_hud_entry.set_SP(_a_SP)
