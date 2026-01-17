extends CutsceneThreadBase
class_name CutsceneThreadExitCutscene

signal request_exit()

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	request_exit.emit()
	
	super()
