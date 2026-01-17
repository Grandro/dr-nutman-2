extends ABSCharacter
class_name ABSEnemy

@onready var _a_HUD: Node3D = get_node("HUD")

func damage(p_dmg: int) -> void:
	set_HP(_a_HP - p_dmg)
	_a_HUD.set_HP(_a_HP)

func set_hud_data(p_max_HP: int, p_max_SP: int) -> void:
	_a_HUD.set_data(p_max_HP, p_max_SP)

func _on_SP_Regen_timeout() -> void:
	super()
	_a_HUD.set_SP(_a_SP)
