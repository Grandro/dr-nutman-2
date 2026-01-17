extends CutsceneThreadBase
class_name CutsceneThreadDefaultObjectKey

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	_emit_completed()
	queue_free()
	
	super()
