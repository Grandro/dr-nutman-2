extends HBoxContainer

@onready var _a_Bust = get_node("Center/Bust")
@onready var _a_HP = get_node("Bars/HP")
@onready var _a_HP_Text = get_node("Bars/HP/Text")
@onready var _a_SP = get_node("Bars/SP")
@onready var _a_SP_Text = get_node("Bars/SP/Text")

var _a_stats = {}
var _a_max_HP = -1
var _a_max_SP = -1

func set_data(p_stats, p_max_HP, p_max_SP, p_bust_texture):
	_a_stats = p_stats
	_a_max_HP = p_max_HP
	_a_max_SP = p_max_SP
	
	_set_bust_texture(p_bust_texture)
	_set_max_HP(p_max_HP)
	_set_max_HP(p_max_SP)
	_set_HP(p_stats["HP"])
	_set_SP(p_stats["SP"])

func _set_bust_texture(p_texture):
	_a_Bust.set_texture(p_texture)

func _set_max_HP(p_value):
	_a_HP.set_max(p_value)

func _set_max_SP(p_value):
	_a_SP.set_max(p_value)

func _set_HP(p_value):
	_a_HP.set_value(p_value)
	var hp_text = "%s/%s" % [str(p_value), str(_a_max_HP)]
	_a_HP_Text.set_text(hp_text)

func _set_SP(p_value):
	_a_SP.set_value(p_value)
	var sp_text = "%s/%s" % [str(p_value), str(_a_max_SP)]
	_a_SP_Text.set_text(sp_text)
