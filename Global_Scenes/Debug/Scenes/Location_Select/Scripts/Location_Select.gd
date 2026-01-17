extends DebugValueSelectOptions
class_name DebugLocationSelect

func update_options() -> void:
	_clear_options()
	
	var maps_data: Dictionary = Databases.get_data(&"Maps")
	var locations: Array[StringName]; locations.assign(maps_data.keys())
	for i: int in maps_data.size():
		var location: StringName = locations[i]
		_a_option_idxs[location] = i
		_a_Value.add_item(location)
		_a_Value.set_item_metadata(i, location)
