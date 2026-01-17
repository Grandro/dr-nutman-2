extends Resource
class_name VoxData

@export var _e_stream: AudioStream = preload("res://Global_Resources/Audio/SFX/Vox/Default.ogg")
@export var _e_pitch: float = 1.0

func get_stream() -> AudioStream:
	return _e_stream

func get_pitch() -> float:
	return _e_pitch
