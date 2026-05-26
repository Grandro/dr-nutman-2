extends Node3D
class_name FWMapBase3D

@export var _e_BGM: FWAudioPlayback = null
@export var _e_BGS: Array[FWAudioPlayback] = []
@export var _e_can_jump: bool = true

var _a_Shared: GDScript = preload("uid://bwcye1ddwlu5x")

var _a_shared: FWMapBaseShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.set_BGM(_e_BGM)
	_a_shared.set_BGS(_e_BGS)
	
	_a_shared.ready()

func get_free_camera() -> Node:
	return _a_shared.get_free_camera()

func get_free_audio() -> Node:
	return _a_shared.get_free_audio()

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_map_data: Dictionary) -> void:
	_a_shared.load_data(p_map_data)

func load_data_init() -> void:
	_a_shared.load_data_init()

func get_can_jump() -> bool:
	return _e_can_jump
