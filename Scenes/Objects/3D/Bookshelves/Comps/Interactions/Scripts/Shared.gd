extends CompInteractionsShared
class_name ObjectBookshelfCompInteractionsShared

var _a_interaction_area: Node

func interaction(p_area: Node) -> void:
	_a_interaction_area = p_area
	super(p_area)

func CB_dialogue_completed(_p_key: StringName) -> void:
	if _a_interaction_area.is_at_last_dialogue_args():
		_a_interaction_area.increase_dialogue_args_idx(1)

func CB_dialogue_choice_selected(_p_key: StringName, p_value: Variant) -> void:
	if p_value:
		_a_interaction_area.increase_dialogue_args_idx(1)
		super.interaction(_a_interaction_area)
