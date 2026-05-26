extends HBoxContainer
class_name MainMenuSubMenuQuestsInfoObjectiveBase

@onready var _a_Desc: Label = get_node("HBox/Desc")

var _a_objective_instance: FWProgressQuestObjectiveBase

func _ready() -> void:
	_a_objective_instance.progressed.connect(_on_Objective_progressed)
	
	var data: FWObjectiveData = _a_objective_instance.get_data()
	var desc: String = data.get_desc()
	var value: Variant = _a_objective_instance.get_value()
	_a_Desc.set_text(desc)
	_set_progress_curr(value)

func set_objective_instance(p_objective_instance: FWProgressQuestObjectiveBase) -> void:
	_a_objective_instance = p_objective_instance

func _set_progress_curr(_p_value) -> void:
	pass

func _on_Objective_progressed() -> void:
	var value: Variant = _a_objective_instance.get_value()
	_set_progress_curr(value)
