extends FWCompInteractionsShared
class_name FWPlayerCompInteractionSystemShared

func init(p_entities: Array[Node]) -> void:
	super(p_entities)
	
	var operate_comp: FWCompOperate = _a_entity_entity_comph.get_comp("Operate")
	operate_comp.to_disabled.connect(_on_Operate_to_disabled)
	operate_comp.to_enabled.connect(_on_Operate_to_enabled)

func _on_Operate_to_disabled() -> void:
	_a_Default_Interaction.set_monitoring(false)

func _on_Operate_to_enabled() -> void:
	_a_Default_Interaction.set_monitoring(true)
