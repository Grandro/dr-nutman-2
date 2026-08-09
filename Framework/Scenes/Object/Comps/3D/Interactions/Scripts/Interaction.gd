extends Area3D
class_name FWCompInteractionsInteraction3D

@export_enum("Walk_In", "Press_Key") var _e_type: String = "Press_Key"
@export var _e_dir_names: Array[StringName] = [&"Down", &"Up", &"Left", &"Right"]
@export var _e_use_dir: bool = false
@export var _e_use_transform: bool = false
@export_enum("Exclamation", "Question", "Speech", "None") var _e_popup_type: String = "Speech"
@export var _e_popup_pos: Vector3 = Vector3.ZERO
@export var _e_speech_bubble_pos: Vector3 = Vector3.ZERO
@export_enum("Main", "Sub") var _e_cutscene_process_type: String = "Main"
@export_enum("Map", "Global") var _e_cutscene_key_type: String = "Map"
@export var _e_cutscene_args: Array[Array] = [] # (Array, Array)
@export var _e_cutscene_args_idx: int = 0
@export_enum("Main", "Sub") var _e_dialogue_process_type: String = "Main"
@export var _e_dialogue_fade_out: bool = true
@export var _e_dialogue_start_idx: int = 0
@export var _e_dialogue_end_idx: int = -1
@export_enum("Map", "Global") var _e_dialogue_key_type: String = "Map"
@export var _e_dialogue_args: Array[StringName] = []
@export var _e_dialogue_args_idx: int = 0

var _a_Shared: GDScript = preload("uid://b2lvsuiqhglew")

var _a_shared: FWCompInteractionsInteractionShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.set_type(_e_type)
	_a_shared.set_dir_names(_e_dir_names)
	_a_shared.set_use_dir(_e_use_dir)
	_a_shared.set_use_transform(_e_use_transform)
	_a_shared.set_popup_type(_e_popup_type)
	_a_shared.set_popup_pos(_e_popup_pos)
	_a_shared.set_speech_bubble_pos(_e_speech_bubble_pos)
	_a_shared.set_cutscene_process_type(_e_cutscene_process_type)
	_a_shared.set_cutscene_key_type(_e_cutscene_key_type)
	_a_shared.set_cutscene_args(_e_cutscene_args)
	_a_shared.set_cutscene_args_idx(_e_cutscene_args_idx)
	_a_shared.set_dialogue_process_type(_e_dialogue_process_type)
	_a_shared.set_dialogue_fade_out(_e_dialogue_fade_out)
	_a_shared.set_dialogue_start_idx(_e_dialogue_start_idx)
	_a_shared.set_dialogue_end_idx(_e_dialogue_end_idx)
	_a_shared.set_dialogue_key_type(_e_dialogue_key_type)
	_a_shared.set_dialogue_args(_e_dialogue_args)
	_a_shared.set_dialogue_args_idx(_e_dialogue_args_idx)

func increase_cutscene_args_idx(p_value: int) -> void:
	_a_shared.increase_cutscene_args_idx(p_value)

func increase_dialogue_args_idx(p_value: int) -> void:
	_a_shared.increase_dialogue_args_idx(p_value)

func is_at_last_dialogue_args() -> bool:
	return _a_shared.is_at_last_dialogue_args()

func increase_interaction_count() -> void:
	_a_shared.increase_interaction_count()

func set_type(p_type: StringName) -> void:
	_a_shared.set_type(p_type)

func get_type() -> StringName:
	return _a_shared.get_type()

func set_dir_names(p_dir_names: Array[StringName]) -> void:
	_a_shared.set_dir_names(p_dir_names)

func get_dir_names() -> Array[StringName]:
	return _a_shared.get_dir_names()

func set_use_dir(p_use_dir: bool) -> void:
	_a_shared.set_use_dir(p_use_dir)

func get_use_dir() -> bool:
	return _a_shared.get_use_dir()

func set_use_transform(p_use_transform: bool) -> void:
	_a_shared.set_use_transform(p_use_transform)

func get_use_transform() -> bool:
	return _a_shared.get_use_transform()

func set_popup_type(p_popup_type: StringName) -> void:
	_a_shared.set_popup_type(p_popup_type)

func get_popup_type() -> StringName:
	return _a_shared.get_popup_type()

func get_popup_pos() -> Vector3:
	return _a_shared.get_popup_pos()

func get_speech_bubble_pos() -> Vector3:
	return _a_shared.get_speech_bubble_pos()

func get_cutscene_process_type() -> StringName:
	return _a_shared.get_cutscene_process_type()

func get_cutscene_key_type() -> StringName:
	return _a_shared.get_cutscene_key_type()

func set_cutscene_args(p_cutscene_args: Array[Array]) -> void:
	_a_shared.set_cutscene_args(p_cutscene_args)

func get_cutscene_args() -> Array[Array]:
	return _a_shared.get_cutscene_args()

func set_cutscene_args_idx(p_cutscene_args_idx: int) -> void:
	_a_shared.set_cutscene_args_idx(p_cutscene_args_idx)

func get_cutscene_args_idx() -> int:
	return _a_shared.get_cutscene_args_idx()

func get_dialogue_process_type() -> StringName:
	return _a_shared.get_dialogue_process_type()

func get_dialogue_fade_out() -> bool:
	return _a_shared.get_dialogue_fade_out()

func get_dialogue_start_idx() -> int:
	return _a_shared.get_dialogue_start_idx()

func get_dialogue_end_idx() -> int:
	return _a_shared.get_dialogue_end_idx()

func get_dialogue_key_type() -> StringName:
	return _a_shared.get_dialogue_key_type()

func set_dialogue_args(p_dialogue_args: Array[StringName]) -> void:
	_a_shared.set_dialogue_args(p_dialogue_args)

func get_dialogue_args() -> Array[StringName]:
	return _a_shared.get_dialogue_args()

func set_dialogue_args_idx(p_dialogue_args_idx: int) -> void:
	_a_shared.set_dialogue_args_idx(p_dialogue_args_idx)

func get_dialogue_args_idx() -> int:
	return _a_shared.get_dialogue_args_idx()

func set_active(p_active: bool) -> void:
	_a_shared.set_active(p_active)

func is_active() -> bool:
	return _a_shared.is_active()

func set_interaction_count(p_interaction_count: int) -> void:
	_a_shared.set_interaction_count(p_interaction_count)

func get_interaction_count() -> int:
	return _a_shared.get_interaction_count()
