extends Node
class_name FWPropertySorter

static func sort(p_parent: Node, p_method_name: StringName, p_rel: String) -> void:
	var sort_arr: Array = []
	var children: Array[Node] = p_parent.get_children()
	for child: Node in children:
		var value: Variant = child.call(p_method_name)
		sort_arr.push_back([value, child])
	sort_arr.sort_custom(Callable(Global, "sort_%s" % p_rel.to_lower()))
	
	for i: int in sort_arr.size():
		var child: Node = sort_arr[i][1]
		p_parent.move_child(child, i)
