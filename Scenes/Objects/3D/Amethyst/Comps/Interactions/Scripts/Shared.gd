extends FWCompInteractionsShared
class_name ObjectAmethystCompInteractionsShared

func interaction(_p_area: Node) -> void:
	var audio_comp: Node = _a_entity_entity_comph.get_comp("Audio")
	audio_comp.play("Pickup")
	
	var global_si: Global = Global.get_singleton(_a_entity, "Global")
	global_si.change_item_amount(&"Amethyst", 1)
	
	set_allowed(false)
	_a_entity_entity.hide()
