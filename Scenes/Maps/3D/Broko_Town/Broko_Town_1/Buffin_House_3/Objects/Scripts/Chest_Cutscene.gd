extends ObjectChestBase
class_name MapBuffinHouse3ObjectChestCutscene

@export var _e_key: StringName = &""
@export var _e_entry_key: StringName = &""

func _opened() -> void:
	super()
	
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(_e_key, _e_entry_key)
