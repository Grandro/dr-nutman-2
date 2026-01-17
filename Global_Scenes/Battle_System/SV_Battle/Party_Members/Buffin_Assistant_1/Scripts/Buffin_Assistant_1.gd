extends SVPartyMember
class_name SVPartyMemberBuffinAssistant1

var _a_help_count: int = 0

func inc_help_count() -> void:
	_a_help_count += 1

func get_help_count() -> int:
	return _a_help_count
