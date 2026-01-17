extends Node

const a_DAMAGE_COLOR: Color = Color8(255, 0, 0)
const a_HEAL_COLOR: Color = Color8(0, 255, 0)

@onready var _a_Battle_SV: BattleSV = get_node("Battle_SV")

func get_battle_sv() -> BattleSV:
	return _a_Battle_SV
