extends MapBase3D

@onready var _a_Player = get_node("Objects/Player")
@onready var _a_Paint_DeLere = get_node("Objects/Paint_DeLere")
@onready var _a_Floor_1 = get_node("Objects/Floor_1")
@onready var _a_Floor_2 = get_node("Objects/Floor_2")

func _ready():
	super()
	var global_si = Global.get_singleton(self, "Global")
	global_si.curr_camera_changed.connect(_on_Global_curr_camera_changed)
	_a_Floor_1.projector_power_changed.connect(_on_projector_power_changed.bind(_a_Floor_1))
	_a_Floor_2.projector_power_changed.connect(_on_projector_power_changed.bind(_a_Floor_2))
	
	_a_Paint_DeLere.set_player(_a_Player)
	_a_Floor_2.set_paint_delere(_a_Paint_DeLere)

func get_save_data():
	var data = super()
	data["Floor_1"] = _a_Floor_1.get_save_data()
	data["Floor_2"] = _a_Floor_2.get_save_data()
	
	return data

func load_data(p_map_data):
	super(p_map_data)
	_a_Floor_1.load_data(p_map_data["Curr_Scene"]["Floor_1"])
	_a_Floor_2.load_data(p_map_data["Curr_Scene"]["Floor_2"])

func _on_Global_curr_camera_changed(p_curr_camera):
	var projection = p_curr_camera.get_projection()
	match projection:
		Camera3D.ProjectionType.PROJECTION_PERSPECTIVE:
			_a_Paint_DeLere.set_billboard(true)
		Camera3D.ProjectionType.PROJECTION_ORTHOGONAL:
			_a_Paint_DeLere.set_billboard(false)

func _on_projector_power_changed(p_projector, p_power, p_floor):
	if p_power:
		_a_Paint_DeLere.set_projector(p_projector)
	
	match p_floor:
		_a_Floor_2:
			_a_Paint_DeLere.set_paint_from_projector(p_power)
