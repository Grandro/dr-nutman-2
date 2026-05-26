extends FWCutsceneThreadBase
class_name FWCutsceneThreadComment

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	queue_free()
	_emit_completed()
	
	super()
