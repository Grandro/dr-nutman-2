extends FWObjectCompBehaviorBase
class_name ArcadeGhostyOrangeCompBehavior

@onready var _a_State_Move: ArcadeGhostyOrangeCompBehaviorStateMove = get_node("States/Move")

func set_state_move_ghosty_pink(p_ghosty_pink: ArcadeGhostyBase) -> void:
	_a_State_Move.set_ghosty_pink(p_ghosty_pink)
