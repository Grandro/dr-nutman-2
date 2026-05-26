extends Resource
class_name FWAudioPlayback

@export var _e_stream: AudioStream = null
@export var _e_volume: float = 1.0
@export var _e_pitch: float = 1.0
@export var _e_from: float = 0.0

func get_stream() -> AudioStream:
	return _e_stream

func get_volume() -> float:
	return _e_volume

func get_pitch() -> float:
	return _e_pitch

func get_from() -> float:
	return _e_from
