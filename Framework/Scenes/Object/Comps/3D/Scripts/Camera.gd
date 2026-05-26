extends Camera3D
class_name FWCompCamera3D

signal made_current()

var _a_limit: Dictionary[Side, float] = {} # Match Side to limit

var _a_base_offset: Vector3 = Vector3.ZERO
var _a_offset: Array[float] = [0.0, 0.0, 0.0, 0.0] # Side to offset

func _ready() -> void:
	_a_limit[SIDE_LEFT] = -10000000.0
	_a_limit[SIDE_TOP] = -10000000.0
	_a_limit[SIDE_RIGHT] = 10000000.0
	_a_limit[SIDE_BOTTOM] = 10000000.0
	
	_a_base_offset = get_position()

func _process(_p_delta: float) -> void:
	if !current:
		return
	
	var top_left: Vector2 = Vector2.ZERO
	var bottom_right: Vector2 = Global.get_base_vp_size()
	var screen_pos: Array[Vector2] = [top_left, bottom_right]
	var world_pos: Array[Vector3] = []
	for curr_screen_pos: Vector2 in screen_pos:
		var origin: Vector3 = project_ray_origin(curr_screen_pos)
		var dir: Vector3 = project_ray_normal(curr_screen_pos)
		var distance: float = -origin.y / dir.y
		var curr_world_pos: Vector3 = origin + dir * distance
		world_pos.push_back(curr_world_pos)
	
	# Top
	var top_diff: float = _a_limit[SIDE_TOP] - (world_pos[0].z - _a_offset[SIDE_TOP])
	_a_offset[SIDE_TOP] = max(0.0, top_diff)
	if _a_offset[SIDE_TOP] > 0.0:
		position.z = _a_base_offset.z + _a_offset[SIDE_TOP]
	
	# Left
	var left_diff: float = _a_limit[SIDE_LEFT] - (world_pos[0].x - _a_offset[SIDE_LEFT])
	_a_offset[SIDE_LEFT] = max(0.0, left_diff)
	if _a_offset[SIDE_LEFT] > 0.0:
		position.x = _a_base_offset.x + _a_offset[SIDE_LEFT]
	
	# Right
	var right_diff: float = _a_limit[SIDE_RIGHT] - (world_pos[1].x - _a_offset[SIDE_RIGHT])
	_a_offset[SIDE_RIGHT] = min(0.0, right_diff)
	if _a_offset[SIDE_RIGHT] < 0.0:
		position.x = _a_base_offset.x + _a_offset[SIDE_RIGHT]
	
	# Down
	var down_diff: float = _a_limit[SIDE_BOTTOM] - (world_pos[1].z - _a_offset[SIDE_BOTTOM])
	_a_offset[SIDE_BOTTOM] = min(0.0, down_diff)
	if _a_offset[SIDE_BOTTOM] < 0.0:
		position.z = _a_base_offset.z + _a_offset[SIDE_BOTTOM]
	
	# No limit => default pos
	if _a_offset[SIDE_LEFT] == 0.0 && _a_offset[SIDE_RIGHT] == 0.0:
		position.x = _a_base_offset.x
	if _a_offset[SIDE_TOP] == 0.0 && _a_offset[SIDE_BOTTOM] == 0.0:
		position.z = _a_base_offset.z

func init(_p_entities: Array[Node]) -> void:
	pass

func make_current_() -> void:
	make_current()
	made_current.emit()

func set_limit(p_margin: Side, p_limit: float) -> void:
	_a_limit[p_margin] = p_limit

func get_limit(p_margin: Side) -> float:
	return _a_limit[p_margin]

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Curr"] = is_current()
	data[&"Size"] = get_size()
	
	return data

func load_data(p_data: Dictionary) -> void:
	if p_data[&"Curr"]:
		var global_si: Global = Global.get_singleton(self, "Global")
		global_si.set_curr_camera(self)
	set_size(p_data[&"Size"])

func load_data_init() -> void:
	pass
