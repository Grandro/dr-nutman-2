extends "res://Scripts/Extension_Base.gd"
class_name CompHandler

signal pre_comps_registered()
signal comps_registered()

var _a_comps = {} # Match comp key to instance

func register_comps(p_entity = _a_entity):
	for instance in _a_entity.get_children():
		if !instance.is_in_group("Comp"):
			continue
		if instance.is_queued_for_deletion():
			continue
		
		var key = instance.get_name()
		_a_comps[key] = instance
	
	for instance in _a_comps.values():
		instance.init(p_entity)
	
	_a_comps["$Main"] = _a_entity
	
	pre_comps_registered.emit()
	comps_registered.emit()

func call_comp(p_key, p_method_name, p_args = []):
	var comp = get_comp(p_key)
	if !comp.has_method(p_method_name):
		push_error("Method ", p_method_name, " not implemented in ", comp)
		return
	var method = Callable(comp, p_method_name)
	
	return method.callv(p_args)

func add_comp(p_instance):
	var key = p_instance.get_name()
	_a_comps[key] = p_instance
	_a_entity.add_child(p_instance)

func remove_comp(p_key):
	var comp = _a_comps[p_key]
	_a_comps.erase(p_key)
	comp.queue_free()

func get_comp(p_key):
	var comp = p_key.get_slice("/", 0)
	if !_has_comp(comp):
		push_error("Comp ", p_key, " not implemented in ", _a_entity)
		return null
	
	var instance = _a_comps[comp]
	if comp.length() == p_key.length():
		return instance
	else:
		p_key = p_key.erase(0, comp.length() + 1)
		return instance.comph().get_comp(p_key)

func get_comps():
	return _a_comps

func has_comp(p_key):
	var comp = p_key.get_slice("/", 0)
	if !_has_comp(comp):
		return false
	
	var instance = _a_comps[comp]
	if comp.length() == p_key.length():
		return true
	else:
		p_key = p_key.erase(0, comp.length() + 1)
		return instance.comph().has_comp(p_key)

func get_entity():
	return _a_entity

func _has_comp(p_key):
	return _a_comps.has(p_key)
