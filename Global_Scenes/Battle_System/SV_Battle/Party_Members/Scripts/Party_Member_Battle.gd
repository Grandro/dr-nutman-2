extends SVCharacter
class_name SVPartyMember

@export var _e_command_circle_offset: Vector3 = Vector3.ZERO
@export var _e_reactions: Dictionary[StringName, Dictionary] = {} # type, reaction_key, button

@onready var _a_Audio: FWCompAudio3D = get_node("Audio")
@onready var _a_Movement_Jump: FWCompMovementJump3D = get_node("Movement/Jump")
@onready var _a_Shield_Bar: SVPartyMemberCompShieldBar = get_node("Shield_Bar")

var _a_actions: Dictionary = {}
var _a_action_on_cd: bool = false # Is action on CD?
var _a_action_time: float = 0.0 # Action timestamp
var _a_action_diff: float = 0.0 # Action timing diff

func _ready() -> void:
	super()
	_a_Movement_Jump.jumped.connect(_on_Movement_Jump_jumped)
	
	set_process_unhandled_input(false)

func _unhandled_input(p_event: InputEvent) -> void:
	if _a_action_on_cd:
		return
	
	if _a_on_turn:
		_process_action_event(p_event)
	else:
		_process_reaction_event(p_event)

func process_action_start() -> void:
	super()
	_process_action_start()

func process_dmg(p_dmg: int) -> void:
	match _a_command:
		&"Defense_DEF":
			var time: float = Time.get_ticks_msec() / 1000.0
			_a_action_diff = time - _a_action_time
			var rating: StringName = get_timing_rating()
			_a_encounter.display_rating(self, rating)
			
			var defense_fac: float = _get_defense_fac(rating)
			var dmg: int = int(p_dmg / defense_fac)
			_a_Stats.decrease_curr_stat(&"HP", dmg)
			
			var shield_gain: int = _get_shield_gain(rating)
			_a_Shield_Bar.open(shield_gain)
		_:
			super(p_dmg)

func reaction_start() -> void:
	_a_action_on_cd = false
	_a_action_diff = 0.0
	set_process_unhandled_input(true)

func reaction_end() -> void:
	set_process_unhandled_input(false)
	_a_States.set_state_tmp(&"Idle")
	_a_Anims.update_anim()

func _process_action_start() -> void:
	match _a_command:
		&"Special": _a_Actions.process_special(_a_special)
		_: _a_Actions.process_command(_a_command)

func _process_action_event(p_event: InputEvent) -> void:
	match _a_command:
		&"Attack_ATK": _process_action_event_attack_ATK(p_event)

func _process_reaction_event(p_event: InputEvent) -> void:
	match _a_command:
		&"Defense_DEF": _process_reaction_event_defend_DEF(p_event)
		_: _process_reaction_event_counter(p_event)

func _process_action_event_attack_ATK(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"OK"):
		_a_action_on_cd = true
		
		_a_Audio.play("Perform")
		var curr_time: float = _a_Anims.get_current_animation_position()
		var max_time: float = _a_Anims.get_current_animation_length()
		_a_action_diff = max_time - curr_time
		
		_a_States.set_state_tmp(&"Attack_ATK_Hit")
		_a_Anims.update_anim()

func _process_reaction_event_defend_DEF(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"OK"):
		_a_action_on_cd = true
		_a_Audio.play("Perform")
		_a_action_time = Time.get_ticks_msec() / 1000.0
		
		_a_States.set_state_tmp(&"Defend_DEF")
		_a_Anims.update_anim()

func _process_reaction_event_counter(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"Jump"):
		_a_action_on_cd = true
		_a_Movement_Jump.jump()
	
	elif p_event.is_action_pressed(&"Duck"):
		_a_action_on_cd = true
		_a_States.set_state_tmp(&"Duck")
		_a_Anims.update_anim()

func get_command_circle_offset() -> Vector3:
	return _e_command_circle_offset

func get_reactions() -> Dictionary[StringName, StringName]:
	var reactions: Dictionary[StringName, StringName]
	if _e_reactions.has(_a_command):
		reactions.assign(_e_reactions[_a_command])
	else:
		reactions.assign(_e_reactions[&"$Default"])
	
	return reactions

func set_actions(p_actions: Dictionary) -> void:
	_a_actions = p_actions
	_a_Actions.update_data(p_actions)

func get_enabled_actions(p_type: StringName) -> Array[StringName]:
	var enabled: Array[StringName] = []
	for key: StringName in _a_actions[p_type]:
		var state: StringName = _a_actions[p_type][key]
		if state == &"Enabled":
			enabled.push_back(key)
	
	return enabled

func set_action_on_cd(p_action_on_cd: bool) -> void:
	_a_action_on_cd = p_action_on_cd

func set_action_diff(p_action_diff: float) -> void:
	_a_action_diff = p_action_diff

func get_timing_rating() -> StringName:
	if !_a_action_on_cd:
		return &"Nothing"
	elif _a_action_diff <= 0.3:
		return &"Excellent"
	elif _a_action_diff <= 0.7:
		return &"Great"
	elif _a_action_diff <= 1.1:
		return &"Good"
	elif _a_action_diff <= 1.3:
		return &"OK"
	
	return &"Nothing"

func _get_defense_fac(p_rating: StringName) -> float:
	match p_rating:
		&"Nothing": return 1.0
		&"OK": return 1.25
		&"Good": return 1.5
		&"Great": return 1.75
		&"Excellent": return 2.0
		_: return 0.0

func _get_shield_gain(p_rating: StringName) -> int:
	match p_rating:
		&"Nothing": return 0
		&"OK": return 1
		&"Good": return 2
		&"Great": return 3
		&"Excellent": return 4
		_: return 0

func _on_Movement_Jump_jumped() -> void:
	_a_action_on_cd = false
	_a_States.set_state_tmp(&"Idle")
	_a_Anims.update_anim()

func _on_Anims_anim_finished(p_name: StringName) -> void:
	if "Duck" in p_name:
		_a_action_on_cd = false
		_a_States.set_state_tmp(&"Idle")
		_a_Anims.update_anim()
