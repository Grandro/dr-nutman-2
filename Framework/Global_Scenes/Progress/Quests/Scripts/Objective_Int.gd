extends FWProgressQuestObjectiveBase
class_name FWProgressQuestObjectiveInt

func manual_progress() -> void:
	_a_value += 1
	progressed.emit()
	
	var target_value: int = _e_data.get_target_value()
	if _a_value == target_value:
		_completed()

func load_data_init() -> void:
	_a_value = 0
