extends FWDebugValueSelectOptions
class_name FWDebugCommandEditValueSelectIdx

var _a_interaction_count: int = -1

func update_options() -> void:
	_clear_options()
	
	for i: int in _a_interaction_count:
		_a_option_idxs[i] = i
		_a_Value.add_item(str(i))
		_a_Value.set_item_metadata(i, i)

func set_interaction_count(p_interaction_count: int) -> void:
	_a_interaction_count = p_interaction_count
