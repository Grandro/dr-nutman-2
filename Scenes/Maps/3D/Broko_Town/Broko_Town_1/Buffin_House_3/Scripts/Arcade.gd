extends FWNode3DObject
class_name Arcade

signal finished()

@export var _e_BGM: AudioStream
@export var _e_dot_collect_streams: Array[AudioStream]

var _a_Battery_Scene: PackedScene = preload("uid://dtg5xwfgpi3wy")

@onready var _a_Below: Node3D = get_node("Below")
@onready var _a_Same_As: Node3D = get_node("Same_As")
@onready var _a_Player: FWPlayer3D = get_node("Player_Arcade")
@onready var _a_Ghosties: FWNode3DObject = get_node("Ghosties")
@onready var _a_Ghosties_Container: Node3D = get_node("Ghosties/Container")
@onready var _a_Ghosty_Red: ArcadeGhostyBase = get_node("Ghosties/Container/Ghosty_Red")
@onready var _a_Ghosty_Orange: ArcadeGhostyBase = get_node("Ghosties/Container//Ghosty_Orange")
@onready var _a_Ghosty_Pink: ArcadeGhostyBase = get_node("Ghosties/Container/Ghosty_Pink")
@onready var _a_Ghosties_Spawn_Pos: Marker3D = get_node("Ghosties/Spawn_Pos")
@onready var _a_Ghosties_Despawn_Pos: Node3D = get_node("Ghosties/Despawn_Pos")
@onready var _a_Dots: Node3D = get_node("Dots")
@onready var _a_Camera: Camera3D = get_node("Camera")
@onready var _a_Ghosty_Spawn_CD: Timer = get_node("Ghosty_Spawn_CD")
@onready var _a_Canvas: CanvasLayer = get_node("Canvas")
@onready var _a_Countdown: FWMiniGameCountdown = get_node("Canvas/Countdown")
@onready var _a_Dots_Value: Label = get_node("Canvas/Dots/HBox/Value")
@onready var _a_Audio_Dot_Collect: AudioStreamPlayer = get_node("Audio/Dot_Collect")
@onready var _a_Audio_Ghosty_Active: AudioStreamPlayer = get_node("Audio/Ghosty_Active")
@onready var _a_Audio_Ghosty_Dazzled: AudioStreamPlayer = get_node("Audio/Ghosty_Dazzled")
@onready var _a_Audio_Ghosty_Return: AudioStreamPlayer = get_node("Audio/Ghosty_Return")

var _a_spawned_ghosties: Array[ArcadeGhostyBase]
var _a_despawned_ghosties: Dictionary[int, ArcadeGhostyBase] # Match despawn_idx to ghosty
var _a_free_despawn_idxs: Array[int]
var _a_dots_remaining: int
var _a_dot_collect_idx: int = 0
var _a_spawn_tween: Tween
var _a_battery: FWNode3DObject

func _ready() -> void:
	super()
	for child: ArcadeGhostyBase in _a_Ghosties_Container.get_children():
		var hitbox_comp: FWCompArea3D = child.comph().get_comp("Hitbox")
		var behavior_comp: FWObjectCompBehaviorBase = child.comph().get_comp("Behavior")
		child.state_changed.connect(_on_Ghosty_state_changed.bind(child))
		hitbox_comp.body_entered.connect(_on_Ghosty_Hitbox_body_entered.bind(child))
		behavior_comp.state_processed.connect(_on_Ghosty_Behavior_state_processed.bind(child))
	for child: ArcadeDot in _a_Dots.get_children():
		child.player_entered.connect(_on_Dot_player_entered.bind(child))
	_a_Ghosty_Spawn_CD.timeout.connect(_on_Ghosty_Spawn_CD_timeout)
	_a_Countdown.finished.connect(_on_Countdown_finished)
	
	_a_Player.comph().call_comp("Operate", &"set_disabled", [1])
	_a_Ghosty_Orange.comph().call_comp("Behavior", &"set_state_move_ghosty_pink", [_a_Ghosty_Pink])
	
	set_process(false)
	_set_visible(true, false)
	_a_Canvas.hide()
	_a_Countdown.hide()

func _process(_p_delta: float) -> void:
	var center: Vector3 = Vector3(86.0, 0.0, 29.0)
	var player_pos: Vector3 = _a_Player.get_position()
	var to_vec: Vector3 = player_pos - center
	_a_Camera.position.x = center.x + to_vec.x * 0.4
	_a_Camera.position.z = center.z + to_vec.z * 0.4

func start() -> void:
	_a_spawned_ghosties = [_a_Ghosty_Red]
	_a_despawned_ghosties = {}
	_a_free_despawn_idxs = [0]
	_a_dots_remaining = _a_Dots.get_child_count()
	_a_Dots_Value.set_text(str(_a_dots_remaining))
	
	_a_Ghosty_Red.set_global_position(_a_Ghosties_Spawn_Pos.global_position)
	for i: int in range(1, _a_Ghosties_Container.get_child_count()):
		var ghosty_instance: ArcadeGhostyBase = _a_Ghosties_Container.get_child(i)
		var pos_instance: Marker3D = _a_Ghosties_Despawn_Pos.get_child(i)
		ghosty_instance.set_global_position(pos_instance.global_position)
		_a_despawned_ghosties[i] = ghosty_instance
	
	_a_Player.set_position(Vector3(86.0, -30.0, 32.5))
	for child: ArcadeGhostyBase in _a_Ghosties_Container.get_children():
		var display_comp: FWCompDisplay3D = child.comph().get_comp("Display")
		display_comp.set_billboard_mode(BaseMaterial3D.BILLBOARD_DISABLED)
		display_comp.set_rotation_degrees(Vector3(-90.0, 0.0, 0.0))
	
	_a_Camera.set_current(true)
	set_process(true)
	_set_visible(true, false)
	
	_a_Countdown.start()

func _spawn_ghosty(p_despawn_idx: int) -> void:
	var instance: ArcadeGhostyBase = _a_despawned_ghosties[p_despawn_idx]
	_a_spawned_ghosties.push_back(instance)
	_a_despawned_ghosties.erase(p_despawn_idx)
	_a_free_despawn_idxs.push_back(p_despawn_idx)
	_a_free_despawn_idxs.sort_custom(Global.sort_high)
	
	_a_spawn_tween = create_tween()
	_a_spawn_tween.finished.connect(_on_Ghosty_Spawn_Tween_finished.bind(instance))
	_a_spawn_tween.tween_property(instance, "global_position", _a_Ghosties_Spawn_Pos.global_position, 1.0)

func _despawn_ghosty(p_instance: ArcadeGhostyBase) -> void:
	var despawn_idx: int = _a_free_despawn_idxs.pop_back()
	_a_spawned_ghosties.erase(p_instance)
	_a_despawned_ghosties[despawn_idx] = p_instance
	
	var pos_instance: Marker3D = _a_Ghosties_Despawn_Pos.get_child(despawn_idx)
	var tween: Tween = create_tween()
	tween.finished.connect(_on_Ghosty_Despawn_Tween_finished.bind(p_instance))
	tween.tween_property(p_instance, "global_position", pos_instance.global_position, 1.0)

func _spawn_battery() -> void:
	_a_battery = _a_Battery_Scene.instantiate()
	_a_battery.set_position(Vector3(86.0, -30.0, 32.5))
	add_child(_a_battery)
	
	var area_comp: FWCompArea3D = _a_battery.comph().get_comp("Area")
	area_comp.body_entered.connect(_on_Battery_Area_body_entered)

func _dot_powerup_collected() -> void:
	_a_Ghosty_Spawn_CD.stop()
	if _a_spawn_tween != null:
		_a_spawn_tween.kill()
	
	for instance: ArcadeGhostyBase in _a_spawned_ghosties:
		var state: StringName = instance.get_state()
		if state != &"Return":
			instance.set_state(&"Dazzled")
	
	_update_ghosty_audio()

func _update_ghosty_audio() -> void:
	var dazzled_count: int = 0
	var return_count: int = 0
	for instance: ArcadeGhostyBase in _a_spawned_ghosties:
		var state: StringName = instance.get_state()
		match state:
			&"Dazzled": dazzled_count += 1
			&"Return": return_count += 1
	
	if return_count > 0:
		_a_Audio_Ghosty_Active.stop()
		_a_Audio_Ghosty_Dazzled.stop()
		_a_Audio_Ghosty_Return.play()
	elif dazzled_count > 0:
		_a_Audio_Ghosty_Active.stop()
		_a_Audio_Ghosty_Return.stop()
		_a_Audio_Ghosty_Dazzled.play()
	elif !_a_spawned_ghosties.is_empty():
		_a_Audio_Ghosty_Dazzled.stop()
		_a_Audio_Ghosty_Return.stop()
		_a_Audio_Ghosty_Active.play()
	else:
		_a_Audio_Ghosty_Active.stop()
		_a_Audio_Ghosty_Dazzled.stop()
		_a_Audio_Ghosty_Return.stop()

func _finish() -> void:
	var file_name: String = _e_BGM.get_path().get_file()
	Audio_Manager.stop_bgm(file_name)
	_a_Player.comph().call_comp("Operate", &"set_disabled", [1])
	
	finished.emit()

func _set_visible(p_visible: bool, p_incl_ghosties: bool) -> void:
	_a_Below.set_visible(p_visible)
	_a_Same_As.set_visible(p_visible)
	if p_incl_ghosties:
		_a_Ghosties.set_visible(p_visible)
	_a_Dots.set_visible(p_visible)
	_a_Canvas.set_visible(p_visible)

func _on_Ghosty_state_changed(p_old_state: StringName, _p_new_state: StringName, p_instance: ArcadeGhostyBase) -> void:
	match p_old_state:
		&"Dazzled":
			if !_a_despawned_ghosties.is_empty() && !p_instance.get_defeated():
				_a_Ghosty_Spawn_CD.start()
			_update_ghosty_audio()
		&"Return":
			_update_ghosty_audio()

func _on_Ghosty_Hitbox_body_entered(_p_body: FWPlayer3D, p_instance: ArcadeGhostyBase) -> void:
	var state: StringName = p_instance.get_state()
	match state:
		&"Normal":
			return
			var scene_manager_si: Scene_Manager = Global.get_singleton(self, "Scene_Manager")
			scene_manager_si.change_scene_dest([&"Game_Over", &"Start"])
		&"Dazzled":
			p_instance.set_state(&"Return")

func _on_Ghosty_Behavior_state_processed(p_state: StringName, p_instance: ArcadeGhostyBase) -> void:
	if p_state == &"Return":
		_despawn_ghosty(p_instance)

func _on_Dot_player_entered(p_instance: ArcadeDot) -> void:
	p_instance.set_disabled(true)
	_a_dots_remaining -= 1
	_a_Dots_Value.set_text(str(_a_dots_remaining))
	
	var stream: AudioStream = _e_dot_collect_streams[_a_dot_collect_idx]
	_a_Audio_Dot_Collect.set_stream(stream)
	_a_Audio_Dot_Collect.play()
	_a_dot_collect_idx = (_a_dot_collect_idx + 1) % _e_dot_collect_streams.size()
	
	if p_instance is ArcadeDotPowerup:
		_dot_powerup_collected()
	if _a_dots_remaining == 0:
		_spawn_battery()

func _on_Ghosty_Spawn_CD_timeout() -> void:
	var despawn_idxs: Array[int]; despawn_idxs.assign(_a_despawned_ghosties.keys())
	despawn_idxs.sort()
	for despawn_idx: int in despawn_idxs:
		if !_a_free_despawn_idxs.has(despawn_idx):
			_spawn_ghosty(despawn_idx)
			break
	
	if !_a_despawned_ghosties.is_empty():
		_a_Ghosty_Spawn_CD.start()

func _on_Countdown_finished() -> void:
	Audio_Manager.play_bgm(_e_BGM)
	_a_Player.comph().call_comp("Operate", &"set_disabled", [0])
	_update_ghosty_audio()
	
	_finish()
	return
	
	_a_Ghosty_Red.comph().call_comp("Behavior", &"set_state", [&"Move"])
	_a_Ghosty_Spawn_CD.start()

func _on_Ghosty_Spawn_Tween_finished(p_instance: ArcadeGhostyBase) -> void:
	p_instance.comph().call_comp("Behavior", &"set_state", [&"Move"])
	_update_ghosty_audio()

func _on_Ghosty_Despawn_Tween_finished(p_instance: ArcadeGhostyBase) -> void:
	var defeated: bool = p_instance.get_defeated()
	p_instance.set_state(&"Normal")
	p_instance.comph().call_comp("Behavior", &"set_state", [&"", false])
	p_instance.comph().call_comp("States", &"set_state", [&"Idle"])
	p_instance.comph().call_comp("Anims", &"update_anim")
	if !defeated:
		_a_Ghosty_Spawn_CD.start()
	_update_ghosty_audio()
	
	if _a_spawned_ghosties.is_empty() && defeated:
		_finish()

func _on_Battery_Area_body_entered(_p_body: FWPlayer3D) -> void:
	_a_battery.queue_free()
	
	# Spawn all despawned ghosties
	var despawn_idxs: Array[int]; despawn_idxs.assign(_a_despawned_ghosties.keys())
	for despawn_idx: int in despawn_idxs:
		if !_a_free_despawn_idxs.has(despawn_idx):
			_spawn_ghosty(despawn_idx)
	
	for instance: ArcadeGhostyBase in _a_spawned_ghosties:
		instance.set_defeated(true)
		instance.set_state(&"Dazzled")
	_update_ghosty_audio()
