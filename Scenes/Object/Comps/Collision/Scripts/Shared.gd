extends ExtensionBase
class_name CompCollisionShared

var _a_entity_entity: Node

func init(p_entity_entity: Node) -> void:
	_a_entity_entity = p_entity_entity
	
	p_entity_entity.visibility_changed.connect(_on_entity_entity_visibility_changed)

func _on_entity_entity_visibility_changed() -> void:
	var visible_: bool = _a_entity_entity.is_visible()
	_a_entity.set_disabled.call_deferred(!visible_)
