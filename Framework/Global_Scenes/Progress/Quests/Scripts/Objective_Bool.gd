extends FWProgressQuestObjectiveBase
class_name FWProgressQuestObjectiveBool

func manual_progress() -> void:
	_a_value = !_a_value
	progressed.emit()
	
	var target_value: bool = _e_data.get_target_value()
	if _a_value == target_value:
		_completed()

func load_data_init() -> void:
	_a_value = false
