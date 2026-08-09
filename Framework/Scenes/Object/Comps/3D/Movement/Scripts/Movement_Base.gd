extends Node3D
class_name FWCompMovementBase3D

signal dir_vec_changed(p_dir_vec: Vector3)

@export var _e_shared: GDScript = preload("uid://3ajqphlh1mir")
@export var _e_limit_dirs: bool = false
@export var _e_dir_names: Array[StringName] = [&"Down", &"Left", &"Right", &"Up"]
@export var _e_reset_dir_vec: Vector3 = Vector3.BACK

var _a_shared: FWCompMovementSharedBase

func _ready() -> void:
	_a_shared = _e_shared.new(self)
	_a_shared.dir_vec_changed.connect(_on_Shared_dir_vec_changed)
	_a_shared.set_limit_dirs(_e_limit_dirs)
	_a_shared.set_dir_names(_e_dir_names)
	_a_shared.set_reset_dir_vec(_e_reset_dir_vec)
	_a_shared.reset_dir_vec()
	
	_a_shared.ready()

func init(p_entities: Array[Node]) -> void:
	_a_shared.init(p_entities)

func comph() -> FWCompHandler:
	return _a_shared.comph()

func stop() -> void:
	_a_shared.stop()

func reset_dir_vec() -> void:
	_a_shared.reset_dir_vec()

func get_velocity() -> Vector3:
	return _a_shared.get_velocity()

func set_dir_vec(p_dir_vec: Vector3) -> void:
	_a_shared.set_dir_vec(p_dir_vec)

func get_dir_vec() -> Vector3:
	return _a_shared.get_dir_vec()

func set_dir_name(p_dir_name: StringName) -> void:
	var dir_vec: Vector3 = Global.get_dir_name_vec_3D(p_dir_name)
	_a_shared.set_dir_vec(dir_vec)

func get_dir_name() -> StringName:
	return _a_shared.get_dir_name()

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

func _on_Shared_dir_vec_changed(p_dir_vec: Vector3) -> void:
	dir_vec_changed.emit(p_dir_vec)
