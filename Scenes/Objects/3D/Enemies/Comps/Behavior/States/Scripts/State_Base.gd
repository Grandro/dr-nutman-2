extends Node
class_name ObjectEnemyCompBehaviorStatesStateBase

signal processed()

@export var _e_keep_state: bool = false
@export var _e_use_CD: bool = true
@export var _e_CD: float = 0.1

var _a_behavior: ObjectEnemyCompBehaviorBase
var _a_entity: Node3D
var _a_entity_comph: CompHandler

func init(p_behavior: ObjectEnemyCompBehaviorBase, p_entity: Node3D, p_entity_comph: CompHandler) -> void:
	_a_behavior = p_behavior
	_a_entity = p_entity
	_a_entity_comph = p_entity_comph

func register(p_actions: Dictionary) -> void:
	p_actions[name] = self

func process_start() -> void:
	pass

func process_end() -> void:
	pass

func get_keep_state() -> bool:
	return _e_keep_state

func get_use_CD() -> bool:
	return _e_use_CD

func get_CD() -> float:
	return _e_CD
