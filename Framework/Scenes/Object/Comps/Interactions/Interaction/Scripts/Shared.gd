extends FWExtensionBase
class_name FWCompInteractionsInteractionShared

var _a_type: StringName
var _a_dir_names: Array[StringName]
var _a_use_dir: bool
var _a_use_transform: bool
var _a_popup_type: StringName
var _a_popup_pos: Variant
var _a_speech_bubble_pos: Variant
var _a_cutscene_process_type: StringName
var _a_cutscene_key_type: StringName
var _a_cutscene_args: Array[Array]
var _a_cutscene_args_idx: int
var _a_dialogue_process_type: StringName
var _a_dialogue_fade_out: bool
var _a_dialogue_start_idx: int
var _a_dialogue_end_idx: int
var _a_dialogue_key_type: StringName
var _a_dialogue_args: Array[StringName]
var _a_dialogue_args_idx: int
var _a_active: bool # Player interacting with this?
var _a_interaction_count: int # Player interaction count

func increase_dialogue_args_idx(p_value: int) -> void:
	var size: int = _a_dialogue_args.size()
	_a_dialogue_args_idx = (_a_dialogue_args_idx + p_value) % size

func increase_cutscene_args_idx(p_value: int) -> void:
	var size: int = _a_cutscene_args.size()
	_a_cutscene_args_idx = (_a_cutscene_args_idx + p_value) % size

func increase_interaction_count() -> void:
	_a_interaction_count += 1

func set_type(p_type: StringName) -> void:
	_a_type = p_type

func get_type() -> StringName:
	return _a_type

func set_dir_names(p_dir_names: Array[StringName]) -> void:
	_a_dir_names = p_dir_names

func get_dir_names() -> Array[StringName]:
	return _a_dir_names

func set_use_dir(p_use_dir: bool) -> void:
	_a_use_dir = p_use_dir

func get_use_dir() -> bool:
	return _a_use_dir

func set_use_transform(p_use_transform: bool) -> void:
	_a_use_transform = p_use_transform

func get_use_transform() -> bool:
	return _a_use_transform

func set_popup_type(p_popup_type: StringName) -> void:
	_a_popup_type = p_popup_type

func get_popup_type() -> StringName:
	return _a_popup_type

func set_popup_pos(p_popup_pos: Variant) -> void:
	_a_popup_pos = p_popup_pos

func get_popup_pos() -> Variant:
	return _a_popup_pos

func set_speech_bubble_pos(p_speech_bubble_pos: Variant) -> void:
	_a_speech_bubble_pos = p_speech_bubble_pos

func get_speech_bubble_pos() -> Variant:
	return _a_speech_bubble_pos

func set_cutscene_process_type(p_cutscene_process_type: StringName) -> void:
	_a_cutscene_process_type = p_cutscene_process_type

func get_cutscene_process_type() -> StringName:
	return _a_cutscene_process_type

func set_cutscene_key_type(p_cutscene_key_type: StringName) -> void:
	_a_cutscene_key_type = p_cutscene_key_type

func get_cutscene_key_type() -> StringName:
	return _a_cutscene_key_type

func set_cutscene_args(p_cutscene_args: Array[Array]) -> void:
	_a_cutscene_args = p_cutscene_args
	_a_cutscene_args_idx = 0

func get_cutscene_args() -> Array[Array]:
	return _a_cutscene_args

func set_cutscene_args_idx(p_cutscene_args_idx: int) -> void:
	_a_cutscene_args_idx = p_cutscene_args_idx

func get_cutscene_args_idx() -> int:
	return _a_cutscene_args_idx

func set_dialogue_process_type(p_dialogue_process_type: StringName) -> void:
	_a_dialogue_process_type = p_dialogue_process_type

func get_dialogue_process_type() -> StringName:
	return _a_dialogue_process_type

func set_dialogue_fade_out(p_dialogue_fade_out: bool) -> void:
	_a_dialogue_fade_out = p_dialogue_fade_out

func get_dialogue_fade_out() -> bool:
	return _a_dialogue_fade_out

func set_dialogue_start_idx(p_dialogue_start_idx: int) -> void:
	_a_dialogue_start_idx = p_dialogue_start_idx

func get_dialogue_start_idx() -> int:
	return _a_dialogue_start_idx

func set_dialogue_end_idx(p_dialogue_end_idx: int) -> void:
	_a_dialogue_end_idx = p_dialogue_end_idx

func get_dialogue_end_idx() -> int:
	return _a_dialogue_end_idx

func set_dialogue_key_type(p_dialogue_key_type: StringName) -> void:
	_a_dialogue_key_type = p_dialogue_key_type

func get_dialogue_key_type() -> StringName:
	return _a_dialogue_key_type

func set_dialogue_args(p_dialogue_args: Array[StringName]) -> void:
	_a_dialogue_args = p_dialogue_args
	_a_dialogue_args_idx = 0

func get_dialogue_args() -> Array[StringName]:
	return _a_dialogue_args

func set_dialogue_args_idx(p_dialogue_args_idx: int) -> void:
	_a_dialogue_args_idx = p_dialogue_args_idx

func get_dialogue_args_idx() -> int:
	return _a_dialogue_args_idx

func is_at_last_dialogue_args() -> bool:
	return _a_dialogue_args_idx == _a_dialogue_args.size() - 1

func set_active(p_active: bool) -> void:
	_a_active = p_active

func is_active() -> bool:
	return _a_active

func set_interaction_count(p_interaction_count: int) -> void:
	_a_interaction_count = p_interaction_count

func get_interaction_count() -> int:
	return _a_interaction_count
