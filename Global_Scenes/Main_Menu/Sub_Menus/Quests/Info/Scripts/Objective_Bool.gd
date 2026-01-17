extends MainMenuSubMenuQuestsInfoObjectiveBase
class_name MainMenuSubMenuQuestsInfoObjectiveBool

@onready var _a_Progress_Curr: CheckBox = get_node("Progress/Curr")

func _set_progress_curr(p_value: bool) -> void:
	_a_Progress_Curr.set_pressed(p_value)
