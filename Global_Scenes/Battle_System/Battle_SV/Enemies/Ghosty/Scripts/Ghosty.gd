extends "res://Global_Scenes/Battle_System/Battle_SV/Enemies/Scripts/Enemy_Battle.gd"

func process_action_start():
	# Possible actions:
	# 1) "Attack_ATK": Float through: 0.7
	# 2) "Float_Invisible": Float through + Invisible: 0.3
	var SP = _a_Stats.get_curr_stat("SP")
	var rndm = randi() % 10
	if rndm <= 4 || SP < 2 || true:
		# Meele attack
		_process_attack_ATK()
	else:
		_process_float_invisible()

func _process_attack_ATK():
	_a_command = "Attack_ATK"
	_pick_target()
	_a_Actions.process_command(_a_command)

func _process_float_invisible():
	_a_command = "Float_Invisible"
	_pick_target()
	_a_Actions.process_command(_a_command)
