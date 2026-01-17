extends Node2D
class_name ABSEnemyHUD

@onready var _a_HP = get_node("VBox/HP")
@onready var _a_SP = get_node("VBox/SP")

var _a_max_HP: int = -1
var _a_max_SP: int = -1

func set_data(p_max_HP: int, p_max_SP: int) -> void:
	_a_max_HP = p_max_HP
	_a_max_SP = p_max_SP
	
	set_max_HP(p_max_HP)
	set_max_SP(p_max_SP)
	set_HP(p_max_HP)
	set_SP(p_max_SP)

func set_max_HP(p_max_HP: int) -> void:
	_a_HP.set_max(p_max_HP)

func set_max_SP(p_max_SP: int) -> void:
	_a_SP.set_max(p_max_SP)
	
func set_HP(p_HP: int) -> void:
	_a_HP.set_value(p_HP)

func set_SP(p_SP: int) -> void:
	_a_SP.set_value(p_SP)
