extends CutsceneThreadBase
class_name CutsceneThreadWaitForSubProcess

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func skip() -> void:
	super()
	
	_emit_completed()
	queue_free()

func sub_process_completed(p_id: StringName) -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var id: StringName = cutscene_system_si.get_option_value(_a_args[&"ID"])
	if p_id == id && !_a_skip:
		_emit_completed()
		queue_free()
