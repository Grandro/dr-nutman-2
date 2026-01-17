extends MainMenuSubMenuQuestsInfoObjectiveBase
class_name MainMenuSubMenuQuestsInfoObjectiveInt

@onready var _a_Progress_Curr: Label = get_node("Progress/Curr")
@onready var _a_Progress_Target: Label = get_node("Progress/Target")

func _ready() -> void:
	super()
	var data: ObjectiveDataInt = _a_objective_instance.get_data()
	var target_value: int = data.get_target_value()
	_a_Progress_Target.set_text(str(target_value))

func _set_progress_curr(p_value: int) -> void:
	_a_Progress_Curr.set_text(str(p_value))
