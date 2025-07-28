extends "res://Scenes/Objects/3D/Enemies/Comps/Behavior/States/Scripts/State_Base.gd"

var _a_nav_agent_comp = null

func init(p_behavior, p_entity, p_entity_comph):
	super(p_behavior, p_entity, p_entity_comph)
	_a_nav_agent_comp = p_entity_comph.get_subcomp("Movement", "Nav_Agent")

func process_start():
	var anims_comp = _a_nav_agent_comp.get_comp("Anims")
	anims_comp.animation_finished.connect(_on_Anims_anim_finished, CONNECT_ONE_SHOT)
	_a_nav_agent_comp.set_path([])
	
	var instance = _a_behavior.get_socialize_instance()
	var entity_pos = _a_entity.get_global_position()
	var body_pos = instance.get_global_position()
	var dir = Global.get_dir_to_pos(entity_pos, body_pos)
	_a_entity_comph.call_comp("Movement", "set_dir", [dir])
	_a_entity_comph.call_comp("States", "set_state", ["Cry"])
	_a_entity_comph.call_comp("Anims", "update_anim")

func process_end():
	var anims_comp = _a_entity_comph.get_comp("Anims")
	if anims_comp.animation_finished.is_connected(_on_Anims_anim_finished):
		anims_comp.animation_finished.disconnect(_on_Anims_anim_finished)

func _on_Anims_anim_finished(p_name):
	if "Cry" in p_name:
		_a_entity_comph.call_comp("States", "set_state", ["Stop"])
		_a_entity_comph.call_comp("Anims", "update_anim")
		
		processed.emit()
