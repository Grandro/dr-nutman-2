extends "res://Global_Scenes/Battle_System/Battle_SV/Character_Battle/Comps/Actions/Commands/Scripts/Attack_ATK.gd"

var _a_Display = null
var _a_Collision = null

func init(p_commands, p_entity):
	super(p_commands, p_entity)
	_a_Display = p_entity.comph().get_comp("Display")
	_a_Collision = p_entity.comph().get_comp("Collision")

func process():
	_a_Collision.set_disabled(true)
	_a_Hitbox.set_monitoring(true)
	super()

func _moved_to_target():
	reaction_finished.emit()
	_a_Collision.set_disabled(false)
	_a_Hitbox.set_monitoring(false)
	
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_a_Display, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT)
	
	var org_pos = _a_Movement.get_org_pos()
	_a_entity.set_global_position(org_pos)

func _on_Tween_finished():
	_moved_to_org_pos()
