extends Object
class_name FWDicRNG

var _a_dic: Dictionary
var _a_total_values: int = 0

func roll_key() -> Variant:
	var rndm: int = randi() % _a_total_values + 1
	var value: int = 0
	for key: Variant in _a_dic:
		value += _a_dic[key]
		if rndm <= value:
			return key
	
	return null

func set_dic(p_dic: Dictionary) -> void:
	_a_dic = p_dic
	
	_a_total_values = 0
	for value: int in p_dic.values():
		_a_total_values += value
