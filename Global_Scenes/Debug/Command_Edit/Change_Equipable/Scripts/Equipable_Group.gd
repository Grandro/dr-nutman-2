extends DebugValueSelectOptions
class_name DebugCommandEditCommandChangeEquipableGroup

func update_options() -> void:
	_clear_options()
	
	var equipment_groups: Array[StringName] = Global.get_equipment_groups()
	for i: int in equipment_groups.size():
		var group: StringName = equipment_groups[i]
		var loc_id: StringName = _e_options_loc_id % group.to_upper()
		_a_option_idxs[group] = i
		_a_Value.add_item(tr(loc_id))
		_a_Value.set_item_metadata(i, group)
