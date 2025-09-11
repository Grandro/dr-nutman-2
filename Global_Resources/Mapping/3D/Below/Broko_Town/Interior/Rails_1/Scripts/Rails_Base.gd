@tool
extends "res://Global_Resources/Mapping/3D/Plane/Scripts/Plane_Tile.gd"

@export_tool_button("Reverse Path") var reverse_path_button = _reverse_path

@onready var _a_Path = get_node("Path")

func _reverse_path():
	var curve = _a_Path.get_curve()
	var points = PackedVector3Array()
	for i in curve.get_point_count():
		var point = curve.get_point_position(i)
		points.push_back(point)
	curve.clear_points()
	for i in range(points.size() - 1, -1, -1):
		var point = points[i]
		curve.add_point(point)

func get_path_curve():
	return _a_Path.get_curve()
