extends Node3D
class_name SVActionsBase

signal started()
signal finished()
signal pre_event()
signal post_event()
signal reaction_started()
signal reaction_finished()
signal hit()

var _a_entity: SVCharacter = null
var _a_args: Dictionary[StringName, ActionData] = {}

func init(p_entity: SVCharacter) -> void:
	_a_entity = p_entity

func process(p_scene: PackedScene) -> void:
	var instance: SVActionBase = _instantiate_action(p_scene)
	add_child(instance)
	
	instance.process()

func update_args(p_args, p_data: Dictionary[StringName, ActionData]) -> void:
	for key: StringName in p_args:
		_a_args[key] = p_data[key]

func _instantiate_action(p_scene: PackedScene) -> SVActionBase:
	var instance: SVActionBase = p_scene.instantiate()
	instance.started.connect(_on_Action_started)
	instance.finished.connect(_on_Action_finished)
	instance.pre_event.connect(_on_Action_pre_event)
	instance.post_event.connect(_on_Action_post_event)
	instance.reaction_started.connect(_on_Action_reaction_started)
	instance.reaction_finished.connect(_on_Action_reaction_finished)
	instance.hit.connect(_on_Action_hit)
	instance.init(self, _a_entity)
	
	return instance

func get_arg(p_action: StringName) -> ActionData:
	return _a_args[p_action]

func get_args() -> Dictionary[StringName, ActionData]:
	return _a_args

func _on_Action_started() -> void:
	started.emit()

func _on_Action_finished() -> void:
	finished.emit()

func _on_Action_pre_event() -> void:
	pre_event.emit()

func _on_Action_post_event() -> void:
	post_event.emit()

func _on_Action_reaction_started() -> void:
	reaction_started.emit()

func _on_Action_reaction_finished() -> void:
	reaction_finished.emit()

func _on_Action_hit() -> void:
	hit.emit()
