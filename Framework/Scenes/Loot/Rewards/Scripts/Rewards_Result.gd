extends FWLootRewardsLoot
class_name FWLootRewardsResult

func open(p_loot: Dictionary[StringName, int]) -> void:
	_instantiate_items(p_loot)
	
	if get_child_count() > 0:
		_fade_in_entry(0)
	else:
		completed.emit()

func _fade_in_entry(p_idx: int) -> void:
	var instance: FWItemEntryResult = get_child(p_idx)
	instance.anim_finished.connect(_on_Entry_anim_finished.bind(p_idx))
	instance.play_anim(&"Fade_In")

func _on_Entry_anim_finished(p_name: StringName, p_idx: int) -> void:
	if p_name == &"Fade_In":
		if get_child_count() - 1 > p_idx:
			_fade_in_entry(p_idx + 1)
		else:
			completed.emit()
