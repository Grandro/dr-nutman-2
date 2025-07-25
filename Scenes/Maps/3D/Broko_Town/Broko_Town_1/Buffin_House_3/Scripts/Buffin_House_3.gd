extends MapBase3D

@onready var _a_Objects = get_node("Objects")
@onready var _a_Player = get_node("Objects/Player")
@onready var _a_Paint_DeLere = get_node("Objects/Paint_DeLere")
@onready var _a_Floor_1 = get_node("Objects/Floor_1")

func _ready():
	super()
	var global_si = Global.get_singleton(self, "Global")
	global_si.curr_camera_changed.connect(_on_Global_curr_camera_changed)
	
	_a_Paint_DeLere.set_player(_a_Player)

func set_paint_delere_projector(p_floor_name, p_projector_name):
	var floor_ = _a_Objects.get_node(p_floor_name)
	var projector = floor_.get_node(p_projector_name)
	_a_Paint_DeLere.set_projector(projector)

func get_save_data():
	var data = super()
	data["Floor_1"] = _a_Floor_1.get_save_data()
	
	return data

func load_data(p_map_data):
	super(p_map_data)
	_a_Floor_1.load_data(p_map_data["Curr_Scene"]["Floor_1"])

func _on_Global_curr_camera_changed(p_curr_camera):
	var projection = p_curr_camera.get_projection()
	match projection:
		Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
			_a_Paint_DeLere.set_billboard(true)
		Camera3D.ProjectionType.PROJECTION_ORTHOGONAL:
			_a_Paint_DeLere.set_billboard(false)
