@tool
extends MeshInstance3D
class_name DebugCommandEditDrawGrid3D

var _a_start: Vector3
var _a_size: Vector2 # Only x and z
var _a_step: Vector3
var _a_y: int = 0 # Current y value for the grid to be displayed on
var _a_surf: SurfaceTool = SurfaceTool.new()

func update_grid() -> void:
	var arr_mesh: ArrayMesh = ArrayMesh.new()
	_a_surf.begin(Mesh.PRIMITIVE_LINES)
	
	for x: int in _a_size.x + 1:
		# Draw z-axis lines
		var line_x: float = _a_start.x + x * _a_step.x
		var from_z: float = _a_start.z
		var to_z: float = from_z + _a_size.y * _a_step.z
		_a_surf.add_vertex(Vector3(line_x, _a_y * _a_step.y, from_z))
		_a_surf.add_vertex(Vector3(line_x, _a_y * _a_step.y, to_z))
	
	for z: int in _a_size.y + 1:
		# Draw x-axis lines
		var line_z: float = _a_start.z + z * _a_step.z
		var from_x: float = _a_start.x
		var to_x: float = from_x + _a_size.x * _a_step.x
		_a_surf.add_vertex(Vector3(from_x, _a_y * _a_step.y, line_z))
		_a_surf.add_vertex(Vector3(to_x, _a_y * _a_step.y, line_z))
	
	_a_surf.index()
	_a_surf.commit(arr_mesh)
	set_mesh(arr_mesh)

func set_start(p_start: Vector3) -> void:
	_a_start = p_start

func get_start() -> Vector3:
	return _a_start

func set_size(p_size: Vector2) -> void:
	_a_size = p_size

func set_step(p_step: Vector3) -> void:
	_a_step = p_step

func set_y(p_y: int) -> void:
	_a_y = p_y
