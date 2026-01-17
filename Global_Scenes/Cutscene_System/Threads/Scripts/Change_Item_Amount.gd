extends CutsceneThreadBase
class_name CutsceneThreadChangeItemAmount

func _ready() -> void:
	super()
	if !_a_loads_data:
		_process_command()

func _process_command() -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	var item_key: StringName = cutscene_system_si.get_option_value(_a_args[&"Item"])
	if !item_key.is_empty():
		var global_si: Global = Global.get_singleton(self, "Global")
		var type: StringName = cutscene_system_si.get_option_value(_a_args[&"Type"])
		var amount: int = cutscene_system_si.get_option_value(_a_args[&"Amount"])
		match type:
			&"Gain": global_si.change_item_amount(item_key, amount)
			&"Lose": global_si.change_item_amount(item_key, -amount)
	
	_emit_completed()
	queue_free()
	
	super()
