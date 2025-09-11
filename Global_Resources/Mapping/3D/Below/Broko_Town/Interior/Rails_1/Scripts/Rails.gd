@tool
extends Node3DObject

@export_tool_button("Update Path") var update_path_button = _update_path
@export var _e_path_closed : bool = false

@onready var _a_Rail_Cars = get_node("Rail_Cars")
@onready var _a_Parts = get_node("Parts")
@onready var _a_Path = get_node("Path")

var _a_path_dir = Vector3.ZERO

func _ready():
	if Engine.is_editor_hint():
		return
	super()
	
	for child in _a_Rail_Cars.get_children():
		child.integrate_forces.connect(_on_Rail_Car_integrate_forces.bind(child))

func _update_path():
	var curve = Curve3D.new()
	for child in _a_Parts.get_children():
		var child_transform = child.get_transform()
		var child_curve = child.get_path_curve()
		for i in child_curve.get_point_count() - 1:
			var point = child_transform * child_curve.get_point_position(i)
			curve.add_point(point)
	curve.set_closed(_e_path_closed)
	
	_a_Path.set_curve(curve)

func _get_closest_point_on_path(p_pos):
	var curve = _a_Path.get_curve()
	var offset = curve.get_closest_offset(p_pos)
	
	return curve.sample_baked(offset)

func _get_path_direction(p_pos):
	var curve = _a_Path.get_curve()
	var offset = curve.get_closest_offset(p_pos)
	var p1 = curve.sample_baked(offset)
	var p2 = curve.sample_baked(offset + 0.1)
	
	return p1.direction_to(p2)

func set_rail_cars_force(p_force):
	for child in _a_Rail_Cars.get_children():
		child.set_force(p_force)

func get_rail_cars():
	return _a_Rail_Cars.get_children()

func get_save_data():
	var data = super()
	data["Rail_Cars"] = []
	for child in _a_Rail_Cars.get_children():
		var child_data = child.get_save_data()
		data["Rail_Cars"].push_back(child_data)
	
	return data

func load_data(p_data):
	super(p_data)
	for i in _a_Rail_Cars.get_child_count():
		var child = _a_Rail_Cars.get_child(i)
		child.load_data(p_data["Rail_Cars"][i])

func _on_Rail_Car_integrate_forces(p_state, p_instance):
	var pos = p_instance.get_position()
	var path_point = _get_closest_point_on_path(pos)
	var dir = _get_path_direction(pos)
	if dir.length() > 0.0:
		_a_path_dir = dir
	
	var velocity = p_state.get_linear_velocity()
	var global_path_point = to_global(path_point)
	p_state.transform.origin.x = global_path_point.x
	p_state.transform.origin.z = global_path_point.z
	p_state.transform.basis.x = _a_path_dir
	p_state.set_linear_velocity(velocity.dot(_a_path_dir) * _a_path_dir)
