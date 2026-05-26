extends ObjectEnemyBase

@onready var _a_Battle_Starter: CompBattleStarter3D = get_node("Battle_Starter")

var _a_dropped_battery: bool = false

func _ready() -> void:
	super()
	_a_Battle_Starter.battle_starting.connect(_on_Battle_Starter_battle_starting)

func _set_dropped_battery(p_dropped_battery: bool) -> void:
	_a_dropped_battery = p_dropped_battery
	if _a_dropped_battery:
		_a_Battle_Starter.remove_bonus_loot(&"Battery")
	else:
		var dic: Dictionary[int, int] = {1: 1}
		_a_Battle_Starter.add_bonus_loot(&"Battery", dic)

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Dropped_Battery"] = _a_dropped_battery
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_set_dropped_battery(p_data[&"Dropped_Battery"])

func load_data_init() -> void:
	super()
	_set_dropped_battery(false)

func _on_Battle_Starter_battle_starting() -> void:
	_set_dropped_battery(true)
