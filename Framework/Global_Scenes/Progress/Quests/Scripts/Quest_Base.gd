extends Node
class_name FWProgressQuestBase

signal completed()

@onready var _a_Objectives: Node = get_node("Objectives")

var _a_active: bool = true # Is quest active or completed?
var _a_completed_objectives_amount: int = 0

func _ready() -> void:
	for child: FWProgressQuestObjectiveBase in _a_Objectives.get_children():
		child.completed.connect(_on_Objective_completed)

func manual_progress_objective(p_objective_name: String) -> void:
	var instance: FWProgressQuestObjectiveBase = _a_Objectives.get_node(p_objective_name)
	instance.manual_progress()

func is_active() -> bool:
	return _a_active

func get_objective_instances() -> Array[Node]:
	return _a_Objectives.get_children()

func get_objective_value(p_objective_name: String) -> Variant:
	var instance: FWProgressQuestObjectiveBase = _a_Objectives.get_node(p_objective_name)
	return instance.get_value()

func get_objective_target_value(p_objective_name: String) -> Variant:
	var instance: FWProgressQuestObjectiveBase = _a_Objectives.get_node(p_objective_name)
	return instance.get_target_value()

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Active"] = _a_active
	data[&"Completed_Objectives_Amount"] = _a_completed_objectives_amount
	
	var objectives_data: Array[Dictionary] = []
	var size: int = _a_Objectives.get_child_count()
	objectives_data.resize(size)
	for i: int in size:
		var child: FWProgressQuestObjectiveBase = _a_Objectives.get_child(i)
		var child_data: Dictionary = child.get_save_data()
		objectives_data[i] = child_data
	data[&"Objectives"] = objectives_data
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	_a_active = p_data[&"Active"]
	_a_completed_objectives_amount = p_data[&"Completed_Objectives_Amount"]
	for i: int in p_data[&"Objectives"].size():
		var child_data: Dictionary = p_data[&"Objectives"][i]
		var child: FWProgressQuestObjectiveBase = _a_Objectives.get_child(i)
		child.load_file_data(child_data)

func load_data_init() -> void:
	for child: FWProgressQuestObjectiveBase in _a_Objectives.get_children():
		child.load_data_init()

func _on_Objective_completed() -> void:
	_a_completed_objectives_amount += 1
	if _a_completed_objectives_amount == _a_Objectives.get_child_count():
		_a_active = false
		completed.emit()
