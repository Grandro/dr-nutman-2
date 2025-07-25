extends Node2D

@onready var _a_HP = get_node("VBox/HP")
@onready var _a_SP = get_node("VBox/SP")

var _a_max_HP = -1
var _a_max_SP = -1

func set_data(p_max_HP, p_max_SP):
	_a_max_HP = p_max_HP
	_a_max_SP = p_max_SP
	
	set_max_HP(p_max_HP)
	set_max_SP(p_max_SP)
	set_HP(p_max_HP)
	set_SP(p_max_SP)

func set_max_HP(p_value):
	_a_HP.set_max(p_value)

func set_max_SP(p_value):
	_a_SP.set_max(p_value)
	
func set_HP(p_value):
	_a_HP.set_value(p_value)

func set_SP(p_value):
	_a_SP.set_value(p_value)
