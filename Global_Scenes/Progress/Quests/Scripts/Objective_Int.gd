extends ProgressQuestObjectiveBase
class_name ProgressQuestObjectiveInt

func manual_progress() -> void:
	_a_value += 1
	progressed.emit()
	
	var target_value: int = _e_data.get_target_value()
	if _a_value == target_value:
		_completed()

func _completed() -> void:
	_a_active = false
	completed.emit()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_value
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_value = p_data[&"Value"]

func load_data_init() -> void:
	_a_value = 0
