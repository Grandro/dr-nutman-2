extends FWDebugCommandEditCommandBase
class_name FWDebugCommandEditCommandPreviewBase

@export var _e_free_camera_scene: PackedScene = null
@export var _e_draw_grid_scene: PackedScene = null
@export var _e_gen_path_scene: PackedScene = null
@export var _e_dimensions: GDScript = preload("uid://b6js3aqbvcggv")

@onready var _a_Preview: FWDebugPreview = get_node("Window/Contents/Margin/HBox/Left/Preview")
@onready var _a_Grid_HBox: HBoxContainer = get_node("Window/Contents/Margin/HBox/Left/Grid")
@onready var _a_Grid_Step: Node = get_node("Window/Contents/Margin/HBox/Left/Grid/Step")
@onready var _a_Grid_Offset: Node = get_node("Window/Contents/Margin/HBox/Left/Grid/Offset")

var _a_Point: Node

var _a_dimensions: FWDebugCommandEditPreviewBaseDimensions

var _a_preview_vp: FWVP = null
var _a_preview_scene: Node = null
var _a_free_camera: Node = null # Camera to freely move around
var _a_draw_grid: Node = null # Instance to draw grid
var _a_gen_path: Node # Instance to gen path

func _ready() -> void:
	_a_OK = get_node("Window/Contents/Margin/HBox/Right/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/HBox/Right/HBox/Cancel")
	super()
	
	_a_Preview.gui_input.connect(_on_Preview_gui_input)
	
	var draw_grid: bool = is_draw_grid()
	_a_Grid_HBox.set_visible(draw_grid)
	
	_create_preview()
	_a_dimensions = _e_dimensions.new(self)

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	update_grid()

func _open_init(_p_res_data: Dictionary) -> void:
	_a_dimensions.open_init()

func _open_load(p_data: Dictionary, _p_res_data: Dictionary) -> void:
	if is_draw_grid():
		_a_dimensions.open_load(p_data)
	if is_gen_path():
		_a_gen_path.open_load(p_data[&"Gen_Path"])

func update_grid() -> void:
	if is_draw_grid():
		var grid_size: Vector2 = Vector2(1000, 1000)
		var grid_step: Variant = _a_Grid_Step.get_value()
		var grid_offset: Variant = _a_Grid_Offset.get_value()
		var grid_start: Variant = grid_offset
		var grid_width: int = int(ceil(grid_size.x / grid_step.x))
		var grid_length: int = _a_dimensions.get_grid_length(grid_size)
		
		_a_draw_grid.set_step(grid_step)
		_a_draw_grid.set_start(grid_start)
		_a_draw_grid.set_size(Vector2(grid_width, grid_length))
		if is_gen_path():
			_a_gen_path.set_step(grid_step)
			_a_gen_path.set_start(grid_start)
			_a_gen_path.update_path()
		
		_a_draw_grid.update_grid()

func _create_preview() -> void:
	_a_Preview.open()
	_a_preview_vp = _a_Preview.get_VP()
	_a_preview_scene = _a_Preview.get_preview_scene()
	
	# Add Camera for free movement
	var objects: Node = _a_preview_scene.get_node("Objects")
	_a_free_camera = _e_free_camera_scene.instantiate()
	_a_free_camera.comph().call_comp.call_deferred("Camera", &"make_current_")
	objects.add_child(_a_free_camera)
	
	if is_draw_grid():
		_a_draw_grid = _e_draw_grid_scene.instantiate()
		if is_gen_path():
			_a_gen_path = _e_gen_path_scene.instantiate()
			_a_gen_path.position.y = 0.05
			_a_gen_path.last_dir_changed.connect(_on_Gen_Path_last_dir_changed)
			_a_gen_path.path_updated.connect(_on_Gen_Path_path_updated)
			_a_preview_scene.add_child(_a_gen_path)
		_a_preview_scene.add_child(_a_draw_grid)

func is_draw_grid() -> bool:
	return _e_draw_grid_scene != null

func is_gen_path() -> bool:
	return _e_gen_path_scene != null

func get_preview_vp_instance() -> FWVP:
	return _a_preview_vp

func get_preview_scene_instance() -> Node:
	return _a_preview_scene

func get_grid_step_instance() -> Node:
	return _a_Grid_Step

func get_grid_offset_instance() -> Node:
	return _a_Grid_Offset

func get_point_instance() -> Node:
	return _a_Point

func get_free_camera_instance() -> Node:
	return _a_free_camera

func get_draw_grid_instance() -> Node:
	return _a_draw_grid

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	if is_draw_grid():
		var grid_step: Variant = _a_Grid_Step.get_value()
		var grid_offset: Variant = _a_Grid_Offset.get_value()
		var grid_start: Variant = grid_offset
		data[&"Grid"] = {}
		data[&"Grid"][&"Step"] = grid_step
		data[&"Grid"][&"Offset"] = grid_offset
		data[&"Grid"][&"Start"] = grid_start
		if is_gen_path():
			data[&"Gen_Path"] = _a_gen_path.get_save_data()
	
	return data

func _on_Preview_gui_input(p_event: InputEvent) -> void:
	if Input.is_action_pressed(&"Mouse_Right"):
		if p_event is InputEventMouseMotion:
			var relative: Vector2 = p_event.get_relative()
			_a_dimensions.handle_free_camera_pan(relative)
	
	if p_event.is_action_pressed(&"Mouse_Wheel_Up"):
		var factor: float = p_event.get_factor()
		_a_dimensions.handle_free_camera_zoom_in(factor)
	
	if p_event.is_action_pressed(&"Mouse_Wheel_Down"):
		var factor: float = p_event.get_factor()
		_a_dimensions.handle_free_camera_zoom_out(factor)

func _on_Gen_Path_last_dir_changed(_p_dir: StringName) -> void:
	pass

func _on_Gen_Path_path_updated() -> void:
	pass
