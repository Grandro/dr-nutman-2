extends SVEnemy
class_name SVEnemyCitrin

func process_action_start() -> void:
	super()
	
	# Possible actions:
	# 1) "Attack_ATK": 0.7
	# 2) "Citrin_Ball_Spew": Citrin ball (Straight / Up): 0.3
	var SP: int = _a_Stats.get_curr_stat(&"SP")
	var rndm: int = randi() % 10
	if rndm <= 6 || SP < 3:
		_process_attack_ATK()
	else:
		_process_citrin_ball_spew()

func _process_attack_ATK() -> void:
	_a_command = &"Attack_ATK"
	_pick_target()
	_a_Actions.process_command(_a_command)

func _process_citrin_ball_spew() -> void:
	_a_command = &"Special"
	_a_special = &"Citrin_Ball_Spew"
	_pick_target()
	_a_Actions.process_special(_a_special)
