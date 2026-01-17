extends Resource
class_name StatsData

@export var _e_HP: int = -1
@export var _e_SP: int = -1
@export var _e_ATK: int = -1
@export var _e_MAG: int = -1
@export var _e_DEF: int = -1
@export var _e_SPEED: int = -1
@export var _e_LUCK: int = -1

func get_HP() -> int:
	return _e_HP

func get_SP() -> int:
	return _e_SP

func get_ATK() -> int:
	return _e_ATK

func get_MAG() -> int:
	return _e_MAG

func get_DEF() -> int:
	return _e_DEF

func get_SPEED() -> int:
	return _e_SPEED

func get_LUCK() -> int:
	return _e_LUCK
