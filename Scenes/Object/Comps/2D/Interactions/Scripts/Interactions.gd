extends Node2D
class_name CompInteractions2D

signal interacted()
signal interaction_activated(p_area: CompInteractionsInteraction2D)
signal interaction_deactivated()

@export var _e_allowed: bool = true
@export var _e_needs_look_at: bool = false
@export var _e_look_at_update: bool = false
@export var _e_look_at_activate: bool = false

var _a_Shared: GDScript = preload("res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd")

var _a_shared: CompInteractionsShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.interacted.connect(_on_Shared_interacted)
	_a_shared.interaction_activated.connect(_on_Shared_interaction_activated)
	_a_shared.interaction_deactivated.connect(_on_Shared_interaction_deactivated)
	_a_shared.set_allowed(_e_allowed)
	_a_shared.set_needs_look_at(_e_needs_look_at)
	_a_shared.set_look_at_update(_e_look_at_update)
	_a_shared.set_look_at_activate(_e_look_at_activate)
	
	_a_shared.ready()

func init(p_entity: Node) -> void:
	_a_shared.init(p_entity)

func interaction(p_area: CompInteractionsInteraction2D) -> void:
	_a_shared.interaction(p_area)

func interaction_update(p_dir: StringName) -> void:
	_a_shared.interaction_update(p_dir)

func interaction_activate(p_area: CompInteractionsInteraction2D, p_dir: StringName) -> void:
	_a_shared.interaction_activate(p_area, p_dir)

func interaction_deactivate(p_area: CompInteractionsInteraction2D) -> void:
	_a_shared.interaction_deactivate(p_area)

func increase_interaction_cutscene_args_idx(p_idx: int, p_value: int = 1) -> void:
	_a_shared.increase_interaction_cutscene_args_idx(p_idx, p_value)

func increase_interaction_dialogue_args_idx(p_idx: int, p_value: int = 1) -> void:
	_a_shared.increase_interaction_dialogue_args_idx(p_idx, p_value)

func set_interaction_cutscene_args_idx(p_idx: int, p_args_idx: int) -> void:
	_a_shared.set_interaction_cutscene_args_idx(p_idx, p_args_idx)

func set_interaction_dialogue_args_idx(p_idx: int, p_args_idx: int) -> void:
	_a_shared.set_interaction_dialogue_args_idx(p_idx, p_args_idx)

func set_allowed(p_allowed: bool) -> void:
	_e_allowed = p_allowed
	_a_shared.set_allowed(p_allowed)

func get_allowed() -> bool:
	return _a_shared.get_allowed()

func get_needs_look_at() -> bool:
	return _a_shared.get_needs_look_at()

func set_look_at_update(p_look_at_update: bool) -> void:
	_a_shared.set_look_at_update(p_look_at_update)

func set_look_at_activate(p_look_at_activate: bool) -> void:
	_a_shared.set_look_at_activate(p_look_at_activate)

func set_interaction_cutscene_args(p_idx: int, p_args: Array[Array]) -> void:
	_a_shared.set_interaction_cutscene_args(p_idx, p_args)

func set_interaction_dialogue_args(p_idx: int, p_args: Array[StringName]) -> void:
	_a_shared.set_interaction_dialogue_args(p_idx, p_args)

func get_default_interaction_pos() -> Vector2:
	return _a_shared.get_default_interaction_pos()

func get_interaction_count(p_idx: int) -> int:
	return _a_shared.get_interaction_count(p_idx)

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_e_allowed = p_data[&"Allowed"]
	_e_needs_look_at = p_data[&"Needs_Look_At"]
	_e_look_at_update = p_data[&"Look_At_Update"]
	_e_look_at_activate = p_data[&"Look_At_Activate"]
	_a_shared.load_data(p_data)

func load_data_init() -> void:
	pass

func _on_Shared_interacted() -> void:
	interacted.emit()

func _on_Shared_interaction_activated(p_area: CompInteractionsInteraction2D) -> void:
	interaction_activated.emit(p_area)

func _on_Shared_interaction_deactivated() -> void:
	interaction_deactivated.emit()
