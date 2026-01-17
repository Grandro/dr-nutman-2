extends HBoxContainer
class_name ABSHUDEntry

@onready var _a_Bust: TextureRect = get_node("Center/Bust")
@onready var _a_HP: ProgressBar = get_node("Bars/HP")
@onready var _a_HP_Text: Label = get_node("Bars/HP/Text")
@onready var _a_SP: ProgressBar = get_node("Bars/SP")
@onready var _a_SP_Text: Label = get_node("Bars/SP/Text")

var _a_stats = {}
var _a_max_HP: int = -1
var _a_max_SP: int = -1

func set_data(p_stats, p_max_HP: int, p_max_SP: int, p_bust_texture: Texture2D) -> void:
	_a_stats = p_stats
	_a_max_HP = p_max_HP
	_a_max_SP = p_max_SP
	
	_set_bust_texture(p_bust_texture)
	_set_max_HP(p_max_HP)
	_set_max_HP(p_max_SP)
	_set_HP(p_stats[&"HP"])
	_set_SP(p_stats[&"SP"])

func _set_bust_texture(p_texture: Texture2D) -> void:
	_a_Bust.set_texture(p_texture)

func _set_max_HP(p_max_HP: int) -> void:
	_a_HP.set_max(p_max_HP)

func _set_max_SP(p_max_SP: int) -> void:
	_a_SP.set_max(p_max_SP)

func _set_HP(p_HP: int) -> void:
	_a_HP.set_value(p_HP)
	var hp_text: String = "%s/%s" % [str(p_HP), str(_a_max_HP)]
	_a_HP_Text.set_text(hp_text)

func _set_SP(p_SP: int) -> void:
	_a_SP.set_value(p_SP)
	var sp_text: String = "%s/%s" % [str(p_SP), str(_a_max_SP)]
	_a_SP_Text.set_text(sp_text)
