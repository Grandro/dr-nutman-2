extends Object
class_name FWExtensionBase

var _a_entity: Node

func _init(p_entity: Node) -> void:
	_a_entity = p_entity
	
	p_entity.tree_exiting.connect(_on_Entity_tree_exiting)

func _on_Entity_tree_exiting() -> void:
	free.call_deferred()
