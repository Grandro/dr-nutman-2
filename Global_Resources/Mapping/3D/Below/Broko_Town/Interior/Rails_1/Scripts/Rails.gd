@tool
extends Node3DObject
class_name Rails

@export_tool_button("Update Path") var _e_update_path_button: Callable = _update_path
@export var _e_path_closed: bool = false

@onready var _a_Rail_Cars: Node3D = get_node("Rail_Cars")
@onready var _a_Parts: Node3D = get_node("Parts")
@onready var _a_Path: Path3D = get_node("Path")

var _a_path_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	super()
	for child: RailCarBase in _a_Rail_Cars.get_children():
		child.integrate_forces.connect(_on_Rail_Car_integrate_forces.bind(child))

func _update_path() -> void:
	var curve: Curve3D = Curve3D.new()
	for child: RailsPartBase in _a_Parts.get_children():
		var child_transform: Transform3D = child.get_transform()
		var child_curve: Curve3D = child.get_path_curve()
		for i: int in child_curve.get_point_count() - 1:
			var point: Vector3 = child_transform * child_curve.get_point_position(i)
			curve.add_point(point)
	curve.set_closed(_e_path_closed)
	
	_a_Path.set_curve(curve)

func _get_closest_point_on_path(p_pos: Vector3) -> Vector3:
	var curve: Curve3D = _a_Path.get_curve()
	var offset: float = curve.get_closest_offset(p_pos)
	
	return curve.sample_baked(offset)

func _get_path_direction(p_pos: Vector3) -> Vector3:
	var curve: Curve3D = _a_Path.get_curve()
	var offset: float = curve.get_closest_offset(p_pos)
	var from: Vector3 = curve.sample_baked(offset)
	var to: Vector3 = curve.sample_baked(offset + 0.1)
	
	return from.direction_to(to)

func set_rail_cars_force(p_force: float) -> void:
	for child: RailCarBase in _a_Rail_Cars.get_children():
		child.set_force(p_force)

func get_rail_cars() -> Array[Node]:
	return _a_Rail_Cars.get_children()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Rail_Cars"] = []
	for child: RailCarBase in _a_Rail_Cars.get_children():
		var child_data: Dictionary = child.get_save_data()
		data[&"Rail_Cars"].push_back(child_data)
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	for i: int in _a_Rail_Cars.get_child_count():
		var child: RailCarBase = _a_Rail_Cars.get_child(i)
		child.load_data(p_data[&"Rail_Cars"][i])

func _on_Rail_Car_integrate_forces(p_state: PhysicsDirectBodyState3D, p_instance: RailCarBase) -> void:
	var pos: Vector3 = p_instance.get_position()
	var path_point: Vector3 = _get_closest_point_on_path(pos)
	var dir: Vector3 = _get_path_direction(pos)
	if dir.length() > 0.0:
		_a_path_dir = dir
	
	var velocity: Vector3 = p_state.get_linear_velocity()
	var global_path_point: Vector3 = to_global(path_point)
	p_state.transform.origin.x = global_path_point.x
	p_state.transform.origin.z = global_path_point.z
	p_state.transform.basis.x = _a_path_dir
	p_state.set_linear_velocity(velocity.dot(_a_path_dir) * _a_path_dir)
