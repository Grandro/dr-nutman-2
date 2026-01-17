extends ObjectEnemyCompBehaviorStatesStateBase
class_name ObjectEnemyCompBehaviorStatesStateAttack

var _a_nav_agent_comp: CompMovementNavAgent3D

func init(p_behavior: ObjectEnemyCompBehaviorBase, p_entity: Node3D, p_entity_comph: CompHandler) -> void:
	super(p_behavior, p_entity, p_entity_comph)
	_a_nav_agent_comp = p_entity_comph.get_comp("Movement/Nav_Agent")

func process_start() -> void:
	var anims_comp: CompAnims = _a_entity_comph.get_comp("Anims")
	anims_comp.animation_finished.connect(_on_Anims_anim_finished, CONNECT_ONE_SHOT)
	_a_nav_agent_comp.set_path([])
	
	var target = _a_behavior.get_target()
	var entity_pos: Vector3 = _a_entity.get_global_position()
	var target_pos: Vector3 = target.get_global_position()
	var dir: StringName = Global.get_dir_to_pos(entity_pos, target_pos)
	_a_entity_comph.call_comp("Movement", &"set_dir", [dir])
	_a_entity_comph.call_comp("States", &"set_state", [&"Shoot"])
	_a_entity_comph.call_comp("Anims", &"update_anim")

func process_end() -> void:
	var anims_comp: CompAnims = _a_entity_comph.get_comp("Anims")
	if anims_comp.animation_finished.is_connected(_on_Anims_anim_finished):
		anims_comp.animation_finished.disconnect(_on_Anims_anim_finished)

func _on_Anims_anim_finished(p_name: StringName) -> void:
	if "Shoot" in p_name:
		_a_entity_comph.call_comp("States", &"set_state", [&"Stop"])
		_a_entity_comph.call_comp("Anims", &"update_anim")
		
		processed.emit()
