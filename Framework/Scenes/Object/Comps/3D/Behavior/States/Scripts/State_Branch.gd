extends Node
class_name FWObjectCompBehaviorStatesStateBranch

signal processed()

var _a_states: Dictionary[StringName, FWObjectCompBehaviorStatesStateBase] = {} # Map state to instance
var _a_instance: FWObjectCompBehaviorStatesStateBase # curr state instance

func init(p_behavior: FWObjectCompBehaviorBase, p_entity: Node3D, p_entity_comph: FWCompHandler) -> void:
	for child: FWObjectCompBehaviorStatesStateBase in get_children():
		child.processed.connect(_on_State_processed)
		child.init(p_behavior, p_entity, p_entity_comph)
		
		var key: StringName = child.get_name()
		_a_states[key] = child

func register(p_actions: Dictionary) -> void:
	p_actions[name] = self

func process_start() -> void:
	var keys: Array[StringName] = _a_states.keys()
	var rndm: int = randi() % keys.size()
	var key: StringName = keys[rndm]
	_a_instance = _a_states[key]
	_a_instance.process_start()

func process_end() -> void:
	_a_instance.process_end()

func get_keep_state() -> bool:
	return _a_instance.get_keep_state()

func get_use_CD() -> bool:
	return _a_instance.get_use_CD()

func get_CD() -> float:
	return _a_instance.get_CD()

func _on_State_processed() -> void:
	processed.emit()
