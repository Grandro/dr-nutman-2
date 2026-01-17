extends Node2D
class_name CompMovementTerrainBase2D

@export var _e_shared: GDScript = preload("res://Scenes/Object/Comps/Movement/Comps/Terrain/Scripts/Shared_Base.gd")
@export var _e_audio_base_path: String = ""
@export var _e_veil_base_path: String = ""

var _a_shared: CompMovementTerrainAreaSharedBase

func _ready() -> void:
	_a_shared = _e_shared.new(self)
	_a_shared.set_audio_base_path(_e_audio_base_path)
	_a_shared.set_veil_base_path(_e_veil_base_path)
	_a_shared.ready()

func init(p_entity: Node) -> void:
	_a_shared.init(p_entity)

func play_audio(p_key: String) -> void:
	_a_shared.play_audio(p_key)

func reset_velocity() -> void:
	_a_shared.reset_velocity()

func adjust_velocity_post(p_velocity: Vector2) -> Vector2:
	return _a_shared.adjust_velocity_post(p_velocity)

func get_velocity_() -> Vector2:
	return _a_shared.get_velocity()

func get_speed() -> float:
	return _a_shared.get_speed()

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass
