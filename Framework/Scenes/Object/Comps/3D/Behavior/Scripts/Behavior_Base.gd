extends Node3D
class_name FWObjectCompBehaviorBase

signal state_processed(p_state: StringName)

@onready var _a_Debug_State: Label3D = get_node("Debug_State")
@onready var _a_Debug_Keep_State: Label3D = get_node("Debug_Keep_State")

@onready var _a_Target_Range: Area3D = get_node("Target_Range")
@onready var _a_States: Node = get_node("States")
@onready var _a_State_CD: Timer = get_node("State_CD")

var _a_entity: FWCharacter3DObject
var _a_entity_comph: FWCompHandler

var _a_states: Dictionary[StringName, Node] = {} # Map state to instance
var _a_stay_area: Area3D
var _a_target: Node3D
var _a_state: StringName = &""
var _a_queued_state: StringName = &""
var _a_keep_state: bool = false

func _process(_p_delta: float) -> void:
	if !_a_keep_state && !_a_queued_state.is_empty():
		set_state(_a_queued_state)
		_set_queued_state(&"")

func init(p_entities: Array[Node]) -> void:
	_a_entity = p_entities[-1]
	_a_entity_comph = _a_entity.comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)
	
	_a_stay_area = _a_entity.get_stay_area()

func _process_state() -> void:
	var instance: Node = _a_states[_a_state]
	instance.process_start()
	
	var keep_state: bool = instance.get_keep_state()
	_set_keep_state(keep_state)

func get_stay_area() -> Area3D:
	return _a_stay_area

func set_target(p_target: Node3D) -> void:
	_a_target = p_target

func get_target() -> Node3D:
	return _a_target

func get_state() -> StringName:
	return _a_state

func get_keep_state() -> bool:
	return _a_keep_state

func set_state(p_state: StringName, p_process: bool = true) -> void:
	if _a_state != &"":
		var instance: Node = _a_states[_a_state]
		instance.process_end()
	_a_state = p_state
	
	_a_Debug_State.set_text(p_state)
	_a_State_CD.stop()
	
	if p_process:
		_process_state()

func _set_queued_state(p_queued_state: StringName) -> void:
	_a_queued_state = p_queued_state

func _set_keep_state(p_keep_state: bool) -> void:
	_a_keep_state = p_keep_state
	_a_Debug_Keep_State.set_text(str(p_keep_state))

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"State"] = _a_state
	
	return data

func load_data(p_data: Dictionary) -> void:
	set_state(p_data[&"State"])

func load_data_init() -> void:
	pass

func _on_Comp_Handler_comps_registered() -> void:
	_a_Target_Range.body_entered.connect(_on_Target_Range_body_entered)
	_a_Target_Range.body_exited.connect(_on_Target_Range_body_exited)
	_a_State_CD.timeout.connect(_on_State_CD_timeout)
	
	for child: Node in _a_States.get_children():
		var state: StringName = child.get_name()
		child.processed.connect(_on_State_processed.bind(state))
		child.init(self, _a_entity, _a_entity_comph)
		child.register(_a_states)

func _on_State_processed(p_state: StringName) -> void:
	var instance: Node = _a_states[p_state]
	if instance.get_use_CD():
		var CD: float = instance.get_CD()
		if CD == 0.0:
			set_state(p_state)
		else:
			_a_State_CD.start(CD)
	
	state_processed.emit(p_state)

func _on_Target_Range_body_entered(_p_body: Node3D) -> void:
	pass

func _on_Target_Range_body_exited(_p_body: Node3D) -> void:
	pass

func _on_State_CD_timeout() -> void:
	set_state(_a_state)
