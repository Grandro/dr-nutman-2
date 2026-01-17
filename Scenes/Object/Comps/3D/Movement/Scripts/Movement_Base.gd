extends Node3D
class_name CompMovementBase3D

signal dir_changed(p_dir: StringName)

@export var _e_shared: GDScript = preload("res://Scenes/Object/Comps/Movement/Scripts/Shared_Base.gd")
@export_enum("Down", "Left", "Right", "Up") var _e_reset_dir: String = "Down"

var _a_shared: CompMovementSharedBase

func _ready() -> void:
	_a_shared = _e_shared.new(self)
	_a_shared.dir_changed.connect(_on_Shared_dir_changed)
	_a_shared.set_reset_dir(_e_reset_dir)
	
	_a_shared.ready()

func init(p_entity: Node) -> void:
	_a_shared.init(p_entity)

func comph() -> CompHandler:
	return _a_shared.comph()

func stop() -> void:
	_a_shared.stop()

func reset_dir() -> void:
	_a_shared.reset_dir()

func get_velocity() -> Vector3:
	return _a_shared.get_velocity()

func set_dir(p_dir: StringName) -> void:
	_a_shared.set_dir(p_dir)

func get_dir() -> StringName:
	return _a_shared.get_dir()

func set_base_speed(p_base_speed: float) -> void:
	_a_shared.set_base_speed(p_base_speed)

func get_speed() -> float:
	return _a_shared.get_speed()

func get_init_velocity() -> Vector3:
	return Vector3.ZERO

func get_save_data() -> Dictionary:
	return _a_shared.get_save_data()

func load_data(p_data: Dictionary) -> void:
	_a_shared.load_data(p_data)

func load_data_init() -> void:
	pass

func _on_Shared_dir_changed(p_dir: StringName) -> void:
	dir_changed.emit(p_dir)
