extends FWCutsceneThreadBase
class_name FWCutsceneThreadChangeCoinsAmount

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var global_si: Global = Global.get_singleton(self, "Global")
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var type: StringName = cutscene_system_si.get_option_value(_a_args[&"Type"])
	var amount: int = cutscene_system_si.get_option_value(_a_args[&"Amount"])
	match type:
		&"Gain": global_si.change_coins_amount(amount)
		&"Lose": global_si.change_coins_amount(-amount)
	
	queue_free()
	_emit_completed()
	
	super()
