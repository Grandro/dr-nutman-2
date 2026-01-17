extends ABSCharacter
class_name ABSPartyMember

var _a_hud_entry: ABSHUDEntry

func damage(p_dmg: int) -> void:
	set_HP(_a_HP - p_dmg)
	_a_hud_entry.set_HP(_a_HP)

func set_hud_entry(p_instance: ABSHUDEntry) -> void:
	_a_hud_entry = p_instance

func _on_SP_Regen_timeout() -> void:
	super()
	_a_hud_entry.set_SP(_a_SP)
