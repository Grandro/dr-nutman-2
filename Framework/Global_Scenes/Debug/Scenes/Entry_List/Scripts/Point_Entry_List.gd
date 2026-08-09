extends FWDebugEntryList
class_name FWDebugPointEntryList

func instantiate_entry_(p_point: Variant, p_name: String = "") -> FWDebugEntryListPointEntry:
	if !_e_enumerate:
		p_name = str(p_point)
	
	var instance: FWDebugEntryListPointEntry = instantiate_entry(p_name)
	instance.set_point(p_point)
	
	return instance

func instantiate_entry_from_data(p_data: Dictionary) -> FWDebugEntryListPointEntry:
	var point: Variant = p_data[&"Point"]
	var name_: String = p_data[&"Name"]
	var instance: FWDebugEntryListPointEntry = instantiate_entry_(point, name_)
	
	return instance

func get_points() -> Array:
	var points: Array = []
	var size_: int = get_entry_count()
	points.resize(size_)
	for i: int in size_:
		var instance: FWDebugEntryListPointEntry = get_entry(i)
		var point: Variant = instance.get_point()
		points[i] = point
	
	return points
