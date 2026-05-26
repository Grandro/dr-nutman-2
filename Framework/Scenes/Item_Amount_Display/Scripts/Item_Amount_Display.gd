extends HBoxContainer
class_name FWItemAmountDisplay

@export var _e_key: StringName = &""

@onready var _a_Text: Label = get_node("Text")

var _a_amount: int

func _ready() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	global_si.item_amount_changed.connect(_on_Global_item_amount_changed)
	
	var amount: int = global_si.get_item_amount(_e_key)
	_set_amount(amount)

func get_amount() -> int:
	return _a_amount

func _set_amount(p_amount: int) -> void:
	_a_Text.set_text(str(p_amount))
	_a_amount = p_amount

func _on_Global_item_amount_changed(p_key: StringName, p_amount: int, _p_diff: int) -> void:
	if p_key == _e_key:
		_set_amount(p_amount)
