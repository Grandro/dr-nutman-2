extends FWExtensionBase
class_name FWCompCollisionShared

var _a_entity_entity: Node

func init(p_entities: Array[Node]) -> void:
	_a_entity_entity = p_entities[-1]
	_a_entity_entity.visibility_changed.connect(_on_entity_entity_visibility_changed)

func _on_entity_entity_visibility_changed() -> void:
	var visible_: bool = _a_entity_entity.is_visible()
	_a_entity.set_disabled.call_deferred(!visible_)
