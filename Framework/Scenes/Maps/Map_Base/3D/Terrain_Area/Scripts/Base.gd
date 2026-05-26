extends Area3D
class_name FWMapTerrainAreaBase3D

@export var _e_audio_keys: Array[String] = []
@export var _e_veil_key: String = ""
@export var _e_speed_mult: float = 1.0

func get_audio_keys() -> Array[String]:
	return _e_audio_keys

func get_veil_key() -> String:
	return _e_veil_key

func get_speed_mult() -> float:
	return _e_speed_mult
