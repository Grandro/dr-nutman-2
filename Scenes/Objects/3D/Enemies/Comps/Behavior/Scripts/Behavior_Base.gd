extends FWObjectCompBehaviorBase
class_name ObjectEnemyCompBehaviorBase

@export var _e_idle_cd: float = 1.0

@onready var _a_Idle_CD: Timer = get_node("Idle_CD")

func set_state(p_state: StringName, p_process: bool = true) -> void:
	super(p_state, p_process)
	_a_Idle_CD.stop()

func load_data(p_data: Dictionary) -> void:
	var state: StringName = p_data[&"State"]
	match state:
		&"In_Battle":
			set_state(&"Respawn")
		
		&"Respawn":
			var progress_si: Progress = Global.get_singleton(self, "Progress")
			var key: StringName = _a_entity_comph.call_comp("Reference", &"get_key")
			var respawn_rdy: bool = progress_si.call_object(key, &"get_respawn_rdy")
			if respawn_rdy:
				set_state(&"Rndm")
				_a_entity.show()
			else:
				set_state(&"Respawn", false)
		
		_:
			super(p_data)

func _on_Comp_Handler_comps_registered() -> void:
	var battle_starter_comp: CompBattleStarter3D = _a_entity_comph.get_comp("Battle_Starter")
	_a_Idle_CD.timeout.connect(_on_Idle_CD_timeout)
	battle_starter_comp.battle_starting.connect(_on_Battle_Starter_battle_starting)
	super()

func _on_State_processed(p_state: StringName) -> void:
	super(p_state)
	if !_a_keep_state:
		_a_Idle_CD.start(_e_idle_cd)

func _on_Idle_CD_timeout() -> void:
	_a_entity_comph.call_comp("States", &"set_state", [&"Idle"])
	_a_entity_comph.call_comp("Anims", &"update_anim")

func _on_Battle_Starter_battle_starting() -> void:
	_a_entity_comph.call_comp("States", &"set_state", [&"Stop"])
	_a_entity_comph.call_comp("Anims", &"update_anim")
	
	set_state(&"In_Battle")
	_a_entity.hide()
