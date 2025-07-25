extends "res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd"

var _a_entity_entity_comph : CompHandler = null

func init(p_entity_entity):
	_a_entity_entity_comph = p_entity_entity.comph()
	super(p_entity_entity)

func interaction(_p_area):
	var audio_comp = _a_entity_entity_comph.get_comp("Audio")
	audio_comp.play("Pickup")
	
	var global_si = Global.get_singleton(_a_entity, "Global")
	global_si.change_item_amount("Amethyst", 1)
	
	set_interaction_allowed(false)
	_a_entity_entity.hide()
