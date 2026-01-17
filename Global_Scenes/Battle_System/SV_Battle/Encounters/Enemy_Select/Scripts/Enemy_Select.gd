extends Node
class_name SVEncounterEnemySelect

signal changed(p_key: StringName, p_init: bool)
signal selected(p_key: StringName)
signal canceled()

@onready var _a_Audio_OK: AudioStreamPlayer = get_node("Audio/OK")
@onready var _a_Audio_Cancel: AudioStreamPlayer = get_node("Audio/Cancel")

var _a_enemy_keys: Array[StringName]
var _a_idx: int = 0 # Idx of selected enemy

func _ready() -> void:
	set_process_unhandled_input(false)

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"OK"):
		var key: StringName = _a_enemy_keys[_a_idx]
		_a_Audio_OK.play()
		selected.emit(key)
		close()
	
	elif p_event.is_action_pressed(&"Cancel"):
		_a_Audio_Cancel.play()
		canceled.emit()
		close()
	
	elif p_event.is_action_pressed(&"Move_Left"):
		var idx: int = (_a_idx - 1) % _a_enemy_keys.size()
		select(idx)
	
	elif p_event.is_action_pressed(&"Move_Right"):
		var idx: int = (_a_idx + 1) % _a_enemy_keys.size()
		select(idx)

func open(p_enemies: Dictionary[StringName, SVEnemy]) -> void:
	_a_enemy_keys = p_enemies.keys()
	
	select(_a_idx, true)
	set_process_unhandled_input(true)

func select(p_idx: int, p_init: bool = false) -> void:
	_a_idx = p_idx
	
	var key: StringName = _a_enemy_keys[p_idx]
	changed.emit(key, p_init)

func close() -> void:
	set_process_unhandled_input(false)
