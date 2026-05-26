extends Node
class_name FWAudioManager

signal bgm_finished(p_file_name: String)
signal sfx_finished(p_file_name: String)
signal bgs_finished(p_file_name: String)

var _a_Pauseable_Audio_Scene: PackedScene = preload("uid://djpas0u08jlp6")

@onready var _a_BGM: Node = get_node("BGM")
@onready var _a_SFX: Node = get_node("SFX")
@onready var _a_BGS: Node = get_node("BGS")

var _a_save_data: Dictionary = {}

var _a_bgm: Dictionary = {} # Match file_name to array of player instances
var _a_bgs: Dictionary = {} # Match file_name to array of player instances

func play_bgm(p_stream: AudioStream, p_volume: float = 1.0, p_pitch: float = 1.0, p_from: float = 0.0) -> FWPausableAudio:
	var path: String = p_stream.get_path()
	var file_name: String = path.get_file()
	var player: FWPausableAudio = _a_Pauseable_Audio_Scene.instantiate()
	player.finished.connect(_on_BGM_finished.bind(player))
	player.tree_exited.connect(_on_BGM_tree_exited.bind(file_name))
	player.set_stream(p_stream)
	player.set_volume_db(linear_to_db(p_volume))
	player.set_pitch_scale(p_pitch)
	player.set_bus(&"BGM")
	player.set_name(file_name)
	player.play.call_deferred(p_from)
	
	if !_a_bgm.has(file_name):
		_a_bgm[file_name] = []
	_a_bgm[file_name].push_back(player)
	
	_set_last_bgm_stream_paused(true)
	
	_a_BGM.add_child(player)
	
	return player

func replace_bgm(p_stream: AudioStream, p_volume: float = 1.0, p_pitch: float = 1.0, p_from: float = 0.0) -> FWPausableAudio:
	var path: String = p_stream.get_path()
	var file_name: String = path.get_file()
	var player: FWPausableAudio = null
	if _a_bgm.has(file_name):
		player = _a_bgm[file_name][-1]
	
	if player == null:
		player = play_bgm(p_stream, p_volume, p_pitch, p_from)
	else:
		player.set_volume_db(linear_to_db(p_volume))
		player.set_pitch_scale(p_pitch)
	
	return player

func flatten_bgm(p_except: FWPausableAudio = null) -> void:
	for child: FWPausableAudio in _a_BGM.get_children():
		if child == p_except:
			continue
		_a_BGM.remove_child(child)
		child.queue_free()

func stop_bgm(p_file_name: String) -> void:
	var players: Array[FWPausableAudio]; players.assign(_a_bgm[p_file_name])
	var player: FWPausableAudio = players[-1]
	_a_BGM.remove_child(player)
	player.queue_free()

func play_bgs(p_stream: AudioStream, p_volume: float = 1.0, p_pitch: float = 1.0, p_from: float = 0.0) -> AudioStreamPlayer:
	var path: String = p_stream.get_path()
	var file_name: String = path.get_file()
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.finished.connect(_on_BGS_finished.bind(player))
	player.tree_exited.connect(_on_BGS_tree_exited.bind(file_name))
	player.set_stream(p_stream)
	player.set_volume_db(linear_to_db(p_volume))
	player.set_pitch_scale(p_pitch)
	player.set_bus(&"BGS")
	player.set_name(file_name)
	player.play.call_deferred(p_from)
	
	if !_a_bgs.has(file_name):
		_a_bgs[file_name] = []
	_a_bgs[file_name].push_back(player)
	
	_a_BGS.add_child(player)
	
	return player

func replace_bgs(p_stream: AudioStream, p_volume: float = 1.0, p_pitch: float = 1.0, p_from: float = 0.0) -> AudioStreamPlayer:
	var path: String = p_stream.get_path()
	var file_name: String = path.get_file()
	var player: AudioStreamPlayer = null
	if _a_bgs.has(file_name):
		player = _a_bgs[file_name][-1]
	
	if player == null:
		player = play_bgs(p_stream, p_volume, p_pitch, p_from)
	else:
		player.set_volume_db(linear_to_db(p_volume))
		player.set_pitch_scale(p_pitch)
	
	return player

func flatten_bgs(p_except: Array[AudioStreamPlayer] = []) -> void:
	for child: AudioStreamPlayer in _a_BGS.get_children():
		if p_except.has(child):
			continue
		_a_BGS.remove_child(child)
		child.queue_free()

func stop_bgs(p_file_name: String) -> void:
	var players: Array[AudioStreamPlayer]; players.assign(_a_bgs[p_file_name])
	var player: AudioStreamPlayer = players[-1]
	_a_BGS.remove_child(player)
	player.queue_free()

func play_sfx(p_stream: AudioStream, p_volume: float = 1.0, p_pitch: float = 1.0, p_from: float = 0.0) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.finished.connect(_on_SFX_finished.bind(player))
	player.set_stream(p_stream)
	player.set_volume_db(linear_to_db(p_volume))
	player.set_pitch_scale(p_pitch)
	player.set_bus(&"SFX")
	player.play.call_deferred(p_from)
	
	_a_SFX.add_child(player)

func reset() -> void:
	_a_save_data.clear()
	for parent: Node in get_children():
		for child: AudioStreamPlayer in parent.get_children():
			parent.remove_child(child)
			child.queue_free()

func _set_last_bgm_stream_paused(p_paused: bool) -> void:
	if _a_BGM.get_child_count() > 0:
		var last: FWPausableAudio = _a_BGM.get_child(-1)
		last.set_stream_paused_(p_paused)

func get_save_data(p_location: StringName) -> Dictionary:
	_a_save_data[p_location] = {}
	var data: Dictionary = _a_save_data[p_location]
	data[&"BGM"] = _get_save_data_bgm()
	data[&"SFX"] = _get_save_data_sfx()
	data[&"BGS"] = _get_save_data_bgs()
	
	return _a_save_data

func _get_save_data_bgm() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for child: FWPausableAudio in _a_BGM.get_children():
		var args: Dictionary = child.get_save_data()
		data.push_back(args)
	
	return data

func _get_save_data_bgs() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for child: AudioStreamPlayer in _a_BGS.get_children():
		var args: Dictionary = {}
		var stream: AudioStream = child.get_stream()
		var stream_path: String = stream.get_path()
		args[&"Stream_Path"] = stream_path
		args[&"Volume"] = child.get_volume_db()
		args[&"Pitch"] = child.get_pitch_scale()
		args[&"Playback_Pos"] = child.get_playback_position()
		
		data.push_back(args)
	
	return data

func _get_save_data_sfx() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	for child: AudioStreamPlayer in _a_SFX.get_children():
		var args: Dictionary = {}
		var stream: AudioStream = child.get_stream()
		var stream_path: String = stream.get_path()
		args[&"Stream_Path"] = stream_path
		args[&"Volume"] = child.get_volume_db()
		args[&"Pitch"] = child.get_pitch_scale()
		args[&"Playback_Pos"] = child.get_playback_position()
		
		data.push_back(args)
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	_a_save_data = p_data

func load_data(p_location: StringName) -> void:
	if !_a_save_data.has(p_location):
		return
	
	var data: Dictionary = _a_save_data[p_location]
	_load_data_bgm(data[&"BGM"])
	_load_data_bgs(data[&"BGS"])
	_load_data_sfx(data[&"SFX"])

func _load_data_bgm(p_args: Array[Dictionary]) -> void:
	var top_player: FWPausableAudio = null
	if _a_BGM.get_child_count() > 0 && !p_args.is_empty():
		top_player = _a_BGM.get_child(-1)
	flatten_bgm(top_player)
	
	for i: int in p_args.size():
		var args: Dictionary = p_args[i]
		var stream_path: String = args[&"Stream_Path"]
		var stream: AudioStream = load(stream_path)
		var volume: float = db_to_linear(args[&"Volume"])
		var pitch: float = args[&"Pitch"]
		var playback_pos: float = args[&"Playback_Pos"]
		var playing: bool = args[&"Playing"]
		
		var player: FWPausableAudio = null
		if i < p_args.size() - 1:
			player = play_bgm(stream, volume, pitch, playback_pos)
		else:
			_set_last_bgm_stream_paused(true)
			player = replace_bgm(stream, volume, pitch, playback_pos)
			
			if player == top_player:
				_a_BGM.move_child(player, -1)
			else:
				if top_player != null:
					_a_BGM.remove_child(top_player)
					top_player.queue_free()
		
		player.set_stream_paused_.call_deferred(!playing)

func _load_data_bgs(p_args: Array[Dictionary]) -> void:
	var players: Array[AudioStreamPlayer] = []
	for i: int in p_args.size():
		var args: Dictionary = p_args[i]
		var stream_path: String = args[&"Stream_Path"]
		var stream: AudioStream = load(stream_path)
		var volume: float = db_to_linear(args[&"Volume"])
		var pitch: float = args[&"Pitch"]
		var playback_pos: float = args[&"Playback_Pos"]
		
		var player: AudioStreamPlayer = replace_bgs(stream, volume, pitch, playback_pos)
		players.push_back(player)
	flatten_bgs(players)

func _load_data_sfx(p_args: Array[Dictionary]) -> void:
	for child: AudioStreamPlayer in _a_SFX.get_children():
		_a_SFX.remove_child(child)
		child.queue_free()
	
	for args: Dictionary in p_args:
		var stream: AudioStream = load(args[&"Stream_Path"])
		var volume: float = db_to_linear(args[&"Volume"])
		var pitch: float = args[&"Pitch"]
		var playback_pos: float = args[&"Playback_Pos"]
		play_sfx(stream, volume, pitch, playback_pos)

func _on_BGM_finished(p_player: FWPausableAudio) -> void:
	var stream: AudioStream = p_player.get_stream()
	var file_path: String = stream.get_path()
	var file_name: String = file_path.get_file()
	stop_bgm(file_name)
	
	bgm_finished.emit(file_name)

func _on_BGM_tree_exited(p_file_name: String) -> void:
	var players: Array[FWPausableAudio]; players.assign(_a_bgm[p_file_name])
	players.pop_back()
	if players.is_empty():
		_a_bgm.erase(p_file_name)
	
	_set_last_bgm_stream_paused(false)

func _on_BGS_finished(p_player: AudioStreamPlayer) -> void:
	var stream: AudioStream = p_player.get_stream()
	var file_path: String = stream.get_path()
	var file_name: String = file_path.get_file()
	stop_bgs(file_name)
	
	bgs_finished.emit(file_name)

func _on_BGS_tree_exited(p_file_name: String) -> void:
	var players: Array[AudioStreamPlayer]; players.assign(_a_bgs[p_file_name])
	players.pop_back()
	if players.is_empty():
		_a_bgs.erase(p_file_name)

func _on_SFX_finished(p_player: AudioStreamPlayer) -> void:
	var stream: AudioStream = p_player.get_stream()
	var file_path: String = stream.get_path()
	var file_name: String = file_path.get_file()
	_a_SFX.remove_child(p_player)
	p_player.queue_free()
	
	sfx_finished.emit(file_name)
