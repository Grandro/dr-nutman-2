extends Resource
class_name FWVoxData

@export var _e_stream: AudioStream = preload("uid://cik7w1nd2jisx")
@export var _e_pitch: float = 1.0

func get_stream() -> AudioStream:
	return _e_stream

func get_pitch() -> float:
	return _e_pitch
