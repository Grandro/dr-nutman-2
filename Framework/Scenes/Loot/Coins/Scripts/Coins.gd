extends MarginContainer
class_name FWLootCoins

@onready var _a_Curr: Label = get_node("Margin/Curr/Text")
@onready var _a_Gain: Label = get_node("Margin/Gain/Text")
@onready var _a_Audio_Gain: AudioStreamPlayer = get_node("Audio/Gain")

var _a_curr_coins: int
var _a_gain_coins: int

func open(p_loot: Dictionary[StringName, int]) -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	_a_curr_coins = global_si.get_coins()
	_a_gain_coins = 0
	if p_loot.has(&"$Coins"):
		_a_gain_coins = p_loot[&"$Coins"]
	
	global_si.change_coins_amount(_a_gain_coins)
	_a_Curr.set_text(str(_a_curr_coins))
	_a_Gain.set_text(str(_a_gain_coins))

func count_up() -> void:
	if _a_gain_coins == 0:
		return
	
	var new_coins: int = _a_curr_coins + _a_gain_coins
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(_set_curr_coins_text, _a_curr_coins, new_coins, 1.0)

func _set_curr_coins_text(p_coins: int) -> void:
	if _a_curr_coins == p_coins:
		return
	
	_a_curr_coins = p_coins
	_a_Curr.set_text(str(p_coins))
	_a_Audio_Gain.play()
