extends SVActionBase
class_name SVPartyMemberBuffinAssistant1CompActionsCommandHelp

func process() -> void:
	started.emit()
	pre_event.emit()
	
	var key: StringName = &"Buffin_Assistant_Help_1"
	var help_count: int = _a_entity.get_help_count()
	var entry_key: StringName = str(help_count)
	_a_entity.cutscene(key, entry_key, _CB_cutscene_completed)

func _CB_cutscene_completed(_p_type: StringName, _p_key: StringName, _p_entry_key: StringName) -> void:
	_a_entity.inc_help_count()
	post_event.emit()
	_finished()
