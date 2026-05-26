extends FWProgressQuestObjectiveBase
class_name FWProgressQuestObjectiveSubQuest

func _ready() -> void:
	if _a_active:
		var progress_si: Progress = Global.get_singleton(self, "Progress")
		progress_si.quest_completed.connect(_on_Progress_quest_completed)
	
	super()

func _update_progress() -> void:
	# Check if Sub_Quest finished
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var sub_quest_data: FWQuestData = _e_data.get_sub_quest()
	var sub_quest_key: StringName = sub_quest_data.get_key()
	if progress_si.is_quest_complete(sub_quest_key):
		_a_value = true
		progressed.emit()
		_completed()

func load_data_init() -> void:
	_a_value = false

func _on_Progress_quest_completed(p_key: StringName) -> void:
	var sub_quest_data: FWQuestData = _e_data.get_sub_quest()
	var sub_quest_key: StringName = sub_quest_data.get_key()
	if p_key == sub_quest_key:
		var progress_si: Progress = Global.get_singleton(self, "Progress")
		progress_si.quest_completed.disconnect(_on_Progress_quest_completed)
		_a_value = true
		progressed.emit()
		_completed()
