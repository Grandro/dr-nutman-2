extends FWCharacter3DObject
class_name SVCharacter

signal action_started()
signal action_finished()
signal action_canceled()
signal action_pre_event()
signal action_post_event()
signal hit(p_target: SVCharacter)
signal died()

@export_enum("Party_Member", "Enemy") var _e_type: String = "Party_Member"
@export var _e_move_state: StringName = &"Walk"
@export var _e_popup_offset: Vector3 = Vector3.ZERO
@export var _e_attack_offset: Vector3 = Vector3.ZERO
@export var _e_rating_offset: Vector3 = Vector3.ZERO

@onready var _a_Movement: CompSVMovementCharacter = get_node("Movement")
@onready var _a_Movement_Nav_Agent: FWCompMovementNavAgent3D = get_node("Movement/Nav_Agent")
@onready var _a_Movement_Knockbacks: FWCompMovementKnockbacks = get_node("Movement/Knockbacks")
@onready var _a_Actions: CompSVActions = get_node("Actions")
@onready var _a_States: FWCompStates = get_node("States")
@onready var _a_Stats: CompSVStats = get_node("Stats")
@onready var _a_Anims: CompSVAnims = get_node("Anims")

var _a_encounter: SVEncounterBase

var _a_target: SVCharacter # Selected target
var _a_command: StringName # Selected command key
var _a_special: StringName # Selected special key
var _a_on_turn: bool = false # Is on turn?
var _a_turn_completed: bool = false # Has completed turn this round?

func _ready() -> void:
	super()
	_a_Movement_Nav_Agent.path_finished.connect(_on_Movement_Nav_Agent_path_finished)
	_a_Movement_Knockbacks.started.connect(_on_Movement_Knockbacks_started)
	_a_Movement_Knockbacks.finished.connect(_on_Movement_Knockbacks_finished)
	_a_Actions.started.connect(_on_Actions_started)
	_a_Actions.finished.connect(_on_Actions_finished)
	_a_Actions.pre_event.connect(_on_Actions_pre_event)
	_a_Actions.post_event.connect(_on_Actions_post_event)
	_a_Actions.hit.connect(_on_Actions_hit)
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)

func process_action_start() -> void:
	_a_on_turn = true
	action_started.emit()

func process_dmg(p_dmg: int) -> void:
	_a_Stats.decrease_curr_stat(&"HP", p_dmg)

func _emit_action_finished() -> void:
	_a_on_turn = false
	set_turn_completed(true)
	action_finished.emit()

func _emit_action_canceled() -> void:
	_a_on_turn = false
	action_canceled.emit()

func cutscene(p_key: StringName, p_entry_key: StringName, p_cb_method: Callable = Callable(),
			  p_process_type: StringName = &"Main", p_key_type: StringName = &"Map") -> void:
	var cutscene_system_si: Cutscene_System = Global.get_singleton(self, "Cutscene_System")
	cutscene_system_si.cutscene(p_key, p_entry_key, p_process_type, p_key_type)
	cutscene_system_si.set_cutscene_completed_cb(p_key, p_entry_key, p_cb_method)

func get_type() -> StringName:
	return _e_type

func get_popup_offset() -> Vector3:
	return _e_popup_offset

func get_attack_offset() -> Vector3:
	return _e_attack_offset

func get_rating_offset() -> Vector3:
	return _e_rating_offset

func set_encounter(p_encounter: SVEncounterBase) -> void:
	_a_encounter = p_encounter

func get_encounter() -> SVEncounterBase:
	return _a_encounter

func set_target(p_target: SVCharacter) -> void:
	_a_target = p_target

func get_target() -> SVCharacter:
	return _a_target

func set_command(p_command: StringName) -> void:
	_a_command = p_command

func get_command() -> StringName:
	return _a_command

func set_special(p_special: StringName) -> void:
	_a_special = p_special

func get_curr_command_arg() -> ActionData:
	return _a_Actions.get_commands_arg(_a_command)

func set_turn_completed(p_turn_completed: bool) -> void:
	_a_turn_completed = p_turn_completed

func get_turn_completed() -> bool:
	return _a_turn_completed

func get_target_attack_pos() -> Vector3:
	var pos: Vector3 = _a_target.get_global_position()
	var attack_offset: Vector3 = _a_target.get_attack_offset()
	var final_pos: Vector3 = pos + attack_offset
	
	return final_pos

func _on_Movement_Nav_Agent_path_finished() -> void:
	var state: StringName = _a_Movement.get_state()
	match state:
		&"Recover_Knockback":
			_a_States.set_state(&"Idle")
			_a_Movement.reset_dir_vec()
			_a_Anims.update_anim()

func _on_Movement_Knockbacks_started() -> void:
	_a_States.set_state_tmp(&"Knockback")
	_a_Anims.update_anim()

func _on_Movement_Knockbacks_finished() -> void:
	await get_tree().create_timer(0.3).timeout
	var HP: int = _a_Stats.get_curr_stat(&"HP")
	if HP == 0:
		_a_States.set_state_tmp(&"Die")
	else:
		_a_States.set_state_tmp(_e_move_state)
		_a_Movement.set_state(&"Recover_Knockback")
		_a_Movement.move_to_org_pos()
	_a_Anims.update_anim()

func _on_Actions_started() -> void:
	action_started.emit()

func _on_Actions_finished() -> void:
	_emit_action_finished()

func _on_Actions_pre_event() -> void:
	action_pre_event.emit()

func _on_Actions_post_event() -> void:
	action_post_event.emit()

func _on_Actions_hit() -> void:
	hit.emit(_a_target)

func _on_Anims_anim_finished(p_name: StringName) -> void:
	if "Die" in p_name:
		died.emit()
