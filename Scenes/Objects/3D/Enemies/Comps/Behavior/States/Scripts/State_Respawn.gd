extends ObjectEnemyCompBehaviorStatesStateBase
class_name ObjectEnemyCompBehaviorStatesStateRespawn

func process_start() -> void:
	var progress_si: Progress = Global.get_singleton(self, "Progress")
	var key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
	progress_si.call_object(key, &"start_respawn")
	
	processed.emit()
