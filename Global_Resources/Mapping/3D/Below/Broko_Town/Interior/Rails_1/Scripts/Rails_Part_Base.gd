@tool
extends PlaneTile
class_name RailsPartBase

@export_tool_button("Reverse Path") var _e_reverse_path_button: Callable = _reverse_path

@onready var _a_Path: Path3D = get_node("Path")

func _reverse_path() -> void:
	var curve: Curve3D = _a_Path.get_curve()
	var points: PackedVector3Array = PackedVector3Array()
	for i: int in curve.get_point_count():
		var point: Vector3 = curve.get_point_position(i)
		points.push_back(point)
	curve.clear_points()
	for i: int in range(points.size() - 1, -1, -1):
		var point: Vector3 = points[i]
		curve.add_point(point)

func get_path_curve() -> Curve3D:
	return _a_Path.get_curve()
