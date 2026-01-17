extends Node3D
class_name SVActionBase

signal started()
signal finished()
signal pre_event()
signal post_event()
signal reaction_started()
signal reaction_finished()
signal hit()

var _a_actions: SVActionsBase
var _a_entity: SVCharacter

func init(p_actions: SVActionsBase, p_entity: SVCharacter) -> void:
	_a_actions = p_actions
	_a_entity = p_entity

func _finished() -> void:
	finished.emit()
	queue_free()
