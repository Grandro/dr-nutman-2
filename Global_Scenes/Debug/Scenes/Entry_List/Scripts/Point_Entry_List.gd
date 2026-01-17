extends DebugEntryList
class_name DebugPointEntryList

func instantiate_entry_(p_point: Variant, p_name: String = "") -> DebugEntryListPointEntry:
	if !_e_enumerate:
		p_name = str(p_point)
	
	var instance: DebugEntryListPointEntry = instantiate_entry(p_name)
	instance.set_point(p_point)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> DebugEntryListPointEntry:
	var point: Variant = p_data[&"Point"]
	var name_: String = p_data[&"Name"]
	var instance: DebugEntryListPointEntry = instantiate_entry_(point, name_)
	
	return instance

func get_points() -> Array:
	var points: Array = []
	for instance: DebugEntryListPointEntry in get_entries():
		var point: Variant = instance.get_point()
		points.push_back(point)
	
	return points
