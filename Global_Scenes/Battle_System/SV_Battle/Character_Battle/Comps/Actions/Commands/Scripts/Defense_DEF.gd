extends SVActionBase
class_name SVActionCommandDefenseDEF

func process() -> void:
	started.emit()
	pre_event.emit()
	post_event.emit()
	_finished()
