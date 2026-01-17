extends SVActionBase
class_name SVPartyMemberCompActionsCommandFlee

var _a_Audio: CompAudio3D
var _a_Movement: CompSVMovementCharacter
var _a_Movement_Nav_Agent: CompMovementNavAgent3D
var _a_States: CompStates
var _a_Anims: CompAnims

var _a_encounter: SVEncounterBase

func init(p_commands: SVActionsBase, p_entity: SVCharacter) -> void:
	super(p_commands, p_entity)
	_a_Audio = p_entity.comph().get_comp("Audio")
	_a_Movement = p_entity.comph().get_comp("Movement")
	_a_Movement_Nav_Agent = p_entity.comph().get_comp("Movement/Nav_Agent")
	_a_States = p_entity.comph().get_comp("States")
	_a_Anims = p_entity.comph().get_comp("Anims")
	_a_encounter = p_entity.get_encounter()
	
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)

func process() -> void:
	started.emit()
	
	var party_members: Dictionary[StringName, SVPartyMember] = _a_encounter.get_party_members()
	var pm_avg_SPEED: float = 0.0
	for instance: SVPartyMember in party_members.values():
		var SPEED: int = instance.comph().call_comp("Stats", &"get_curr_stat", [&"SPEED"])
		pm_avg_SPEED += SPEED
	pm_avg_SPEED /= party_members.size()
	
	var enemies: Dictionary[StringName, SVEnemy] = _a_encounter.get_enemies()
	var enemies_avg_SPEED: float = 0.0
	for instance: SVEnemy in enemies.values():
		var SPEED: int = instance.comph().call_comp("Stats", &"get_curr_stat", [&"SPEED"])
		enemies_avg_SPEED += SPEED
	enemies_avg_SPEED /= enemies.size()
	
	pre_event.emit()
	if pm_avg_SPEED >= enemies_avg_SPEED:
		_process_success(party_members)
	else:
		_process_fail()
	post_event.emit()

func _process_success(p_party_members: Dictionary[StringName, SVPartyMember]) -> void:
	var flee_pos: Vector3 = _a_encounter.get_flee_pos()
	for instance: SVPartyMember in p_party_members.values():
		var pos: Vector3 = instance.get_global_position()
		flee_pos = Vector3(flee_pos.x, pos.y, pos.z)
		
		_a_Audio.play("Flee")
		_a_States.set_state(&"Walk")
		_a_Movement.set_state(&"Move_To_Flee_Pos")
		_a_Movement.move_to_pos(flee_pos)
		_a_Anims.update_anim()

func _process_fail() -> void:
	pass

func _on_Movement_Nav_Agent_path_finished() -> void:
	var state: StringName = _a_Movement.get_state()
	match state:
		&"Move_To_Flee_Pos":
			_finished()
