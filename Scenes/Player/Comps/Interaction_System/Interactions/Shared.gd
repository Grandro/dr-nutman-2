extends CompInteractionsShared
class_name PlayerCompInteractionSystemShared

func init(p_entity_entity: Node) -> void:
	super(p_entity_entity)
	
	var entity_entity_comph: CompHandler = p_entity_entity.comph()
	var operate_comp: CompOperate = entity_entity_comph.get_comp("Operate")
	operate_comp.to_disabled.connect(_on_Operate_to_disabled)
	operate_comp.to_enabled.connect(_on_Operate_to_enabled)

func _on_Operate_to_disabled() -> void:
	_a_Default_Interaction.set_monitoring(false)

func _on_Operate_to_enabled() -> void:
	_a_Default_Interaction.set_monitoring(true)
