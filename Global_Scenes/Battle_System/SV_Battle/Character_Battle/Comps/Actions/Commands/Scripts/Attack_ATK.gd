extends SVActionBase
class_name SVActionCommandAttackATK

@export var _e_move_state: StringName = &"Walk"
@export var _e_offset: Vector3 = Vector3.ZERO

var _a_Audio: FWCompAudio3D
var _a_Hitbox: FWCompArea3D
var _a_Movement: CompSVMovementCharacter
var _a_Movement_Nav_Agent: FWCompMovementNavAgent3D
var _a_States: FWCompStates
var _a_Anims: CompSVAnims

func init(p_commands: SVActionsBase, p_entity: SVCharacter) -> void:
	super(p_commands, p_entity)
	_a_Audio = p_entity.comph().get_comp("Audio")
	_a_Hitbox = p_entity.comph().get_comp("Hitbox")
	_a_Movement = p_entity.comph().get_comp("Movement")
	_a_Movement_Nav_Agent = p_entity.comph().get_comp("Movement/Nav_Agent")
	_a_States = p_entity.comph().get_comp("States")
	_a_Anims = p_entity.comph().get_comp("Anims")
	
	_a_Hitbox.body_entered.connect(_on_Hitbox_body_entered)
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func process() -> void:
	var pos: Vector3 = _a_entity.get_target_attack_pos() + _e_offset
	_a_States.set_state(_e_move_state)
	_a_Movement.set_state(&"Move_To_Target")
	_a_Movement.move_to_pos(pos)
	_a_Anims.update_anim()
	
	started.emit()
	reaction_started.emit()

func _moved_to_target() -> void:
	pass

func _moved_to_org_pos() -> void:
	_a_States.set_state(&"Idle")
	_a_Movement.reset_dir()
	_a_Anims.update_anim()
	_finished()

func _on_Hitbox_body_entered(_p_body: Node3D) -> void:
	_a_Hitbox.set_deferred(&"monitoring", false)
	_a_Audio.play("Hit")
	hit.emit()

func _on_Movement_Nav_Agent_path_finished() -> void:
	var state: StringName = _a_Movement.get_state()
	match state:
		&"Move_To_Target": _moved_to_target()
		&"Move_To_Org_Pos": _moved_to_org_pos()

func _on_Anims_anim_finished(_p_name: StringName) -> void:
	pass
