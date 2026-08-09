extends Node
class_name FWPropertySorter

static func sort(p_parent: Node, p_method_name: StringName, p_rel: String) -> void:
	var sort_arr: Array = []
	var size: int = p_parent.get_child_count()
	sort_arr.resize(size)
	for i: int in size:
		var child: Node = p_parent.get_child(i)
		var value: Variant = child.call(p_method_name)
		sort_arr[i] = [value, child]
	sort_arr.sort_custom(Callable(Global, "sort_%s" % p_rel.to_lower()))
	
	for i: int in size:
		var child: Node = sort_arr[i][1]
		p_parent.move_child(child, i)
