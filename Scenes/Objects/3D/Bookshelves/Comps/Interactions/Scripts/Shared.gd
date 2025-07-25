extends "res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd"

var _a_interaction_area = null

func interaction(p_area):
	_a_interaction_area = p_area
	super(p_area)

func CB_dialogue_completed(_p_key):
	if _a_interaction_area.is_at_last_dialogue_args():
		_a_interaction_area.increase_dialogue_args_idx(1)

func CB_dialogue_choice_selected(_p_key, p_value):
	if p_value:
		_a_interaction_area.increase_dialogue_args_idx(1)
		super.interaction(_a_interaction_area)
