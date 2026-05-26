extends Area2D
class_name FWCompMovementTerrainArea2D

var _a_Shared: GDScript = preload("uid://b0avkhagxy7u1")

var _a_shared: FWCompMovementTerrainAreaShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.ready()

func play_audio() -> void:
	_a_shared.play_audio()

func set_audio_base_path(p_audio_base_path: String) -> void:
	_a_shared.set_audio_base_path(p_audio_base_path)

func set_veil_base_path(p_veil_base_path: String) -> void:
	_a_shared.set_veil_base_path(p_veil_base_path)

func get_areas() -> Array[Node]:
	return _a_shared.get_areas()
