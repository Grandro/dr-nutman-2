extends FWExtensionBase
class_name FWCompHandler

signal pre_comps_registered()
signal comps_registered()

var _a_comps: Dictionary[StringName, Node] = {} # Match comp key to instance
var _a_entities: Array[Node]

func register_comps(p_entities: Array[Node] = [_a_entity]) -> void:
	_a_entities = p_entities
	
	for instance: Node in _a_entity.get_children():
		if _is_valid_comp(instance):
			var key: StringName = instance.get_name()
			_a_comps[key] = instance
	
	for instance: Node in _a_comps.values():
		instance.init(p_entities)
	_a_comps[&"$Main"] = _a_entity
	
	pre_comps_registered.emit()
	comps_registered.emit()

func call_comp(p_key: String, p_method_name: StringName, p_args: Array = []) -> Variant:
	var comp: Node = get_comp(p_key)
	if !comp.has_method(p_method_name):
		push_error("Method ", p_method_name, " not implemented in ", comp)
		return
	var method: Callable = Callable(comp, p_method_name)
	
	return method.callv(p_args)

func add_comp(p_instance: Node) -> void:
	var key: StringName = p_instance.get_name()
	_a_comps[key] = p_instance
	_a_entity.add_child(p_instance)
	p_instance.init(_a_entities)

func remove_comp(p_key: StringName) -> void:
	var comp: Node = _a_comps[p_key]
	_a_comps.erase(p_key)
	_a_entity.remove_child(comp)
	comp.queue_free()

func clear_comps() -> void:
	for key: StringName in _a_comps:
		var instance: Node = _a_comps[key]
		if instance == _a_entity:
			continue
		_a_entity.remove_child(instance)
		instance.queue_free()
	_a_comps.clear()

func get_comp(p_key: String) -> Node:
	var comp: StringName = p_key.get_slice("/", 0)
	if !_has_comp(comp):
		push_error("Comp ", p_key, " not implemented in ", _a_entity)
		return null
	
	var instance: Node = _a_comps[comp]
	if comp.length() == p_key.length():
		return instance
	else:
		p_key = p_key.erase(0, comp.length() + 1)
		return instance.comph().get_comp(p_key)

func get_comps() -> Dictionary[StringName, Node]:
	return _a_comps

func has_comp(p_key: String) -> bool:
	var comp: StringName = p_key.get_slice("/", 0)
	if !_has_comp(comp):
		return false
	
	var instance: Node = _a_comps[comp]
	if comp.length() == p_key.length():
		return true
	else:
		p_key = p_key.erase(0, comp.length() + 1)
		return instance.comph().has_comp(p_key)

func get_entity() -> Node:
	return _a_entity

func _has_comp(p_key: StringName) -> bool:
	return _a_comps.has(p_key)

func _is_valid_comp(p_instance: Node) -> bool:
	if p_instance.is_queued_for_deletion():
		return false
	if !p_instance.is_in_group(&"Comp"):
		return false
	return true
