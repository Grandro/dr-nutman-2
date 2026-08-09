extends Node
class_name FWObjectCompBehaviorStatesStateBase

signal processed()

@export var _e_use_process_time: bool = false
@export var _e_process_time: float = 0.1 # If !wait_finish process this long
@export var _e_keep_state: bool = false
@export var _e_use_CD: bool = true
@export var _e_CD: float = 0.1

@onready var _a_Process_Time: Timer = get_node("Process_Time")

var _a_behavior: FWObjectCompBehaviorBase
var _a_entity: Node3D
var _a_entity_comph: FWCompHandler

func _ready() -> void:
	_a_Process_Time.timeout.connect(_on_Process_Time_timeout)

func init(p_behavior: FWObjectCompBehaviorBase, p_entity: Node3D, p_entity_comph: FWCompHandler) -> void:
	_a_behavior = p_behavior
	_a_entity = p_entity
	_a_entity_comph = p_entity_comph

func register(p_actions: Dictionary) -> void:
	p_actions[name] = self

func process_start() -> void:
	if _e_use_process_time:
		_a_Process_Time.start(_e_process_time)

func process_end() -> void:
	_a_Process_Time.stop()

func get_keep_state() -> bool:
	return _e_keep_state

func get_use_CD() -> bool:
	return _e_use_CD

func get_CD() -> float:
	return _e_CD

func _on_Process_Time_timeout() -> void:
	processed.emit()
