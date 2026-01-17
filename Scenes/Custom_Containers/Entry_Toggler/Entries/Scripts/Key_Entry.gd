extends EntryTogglerEntry
class_name EntryTogglerKeyEntry

var _a_key: StringName

func set_key(p_key: StringName) -> void:
	_a_key = p_key

func get_key() -> StringName:
	return _a_key
