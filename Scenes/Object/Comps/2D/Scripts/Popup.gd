extends Sprite2D
class_name CompPopup2D

signal finished()

var _a_Shared: GDScript = preload("res://Scenes/Object/Comps/Popup/Scripts/Shared.gd")

var _a_shared: CompPopupShared

func _ready() -> void:
	_a_shared = _a_Shared.new(self)
	_a_shared.finished.connect(_on_Shared_finished)
	
	_a_shared.ready()

func init(p_entity: Node) -> void:
	_a_shared.init(p_entity)

func popup(p_type: String, p_by_command: bool) -> void:
	_a_shared.popup(p_type, p_by_command)

func update_texture(p_type: StringName) -> void:
	_a_shared.update_texture(p_type)

func reset() -> void:
	_a_shared.reset()

func play_anim(p_name: StringName) -> void:
	_a_shared.play_anim(p_name)

func seek_anim(p_seconds: float, p_update: bool = false) -> void:
	_a_shared.seek_anim(p_seconds, p_update)

func start_timer(p_seconds: float) -> void:
	_a_shared.start_timer(p_seconds)

func get_anim_pos() -> float:
	return _a_shared.get_anim_pos()

func get_assigned_anim() -> String:
	return _a_shared.get_assigned_anim()

func get_timer_time_left() -> float:
	return _a_shared.get_timer_time_left()

func get_save_data() -> Dictionary:
	return {}

func load_data(_p_data: Dictionary) -> void:
	pass

func load_data_init() -> void:
	pass

func _on_Shared_finished() -> void:
	finished.emit()
