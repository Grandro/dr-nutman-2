extends FWDebugCommandEditCommandPreviewObject
class_name FWDebugCommandEditCommandPreviewObjectPath

@export var _e_selected_color: Color = Color(1.0, 0.84, 0.0)
@export var _e_normal_color: Color = Color.WHITE

const _a_PATH_PATH: String = "res://Framework/Global_Scenes/Debug/Sprites/Path/%s.png"

@onready var _a_Path_Points: FWDebugPointEntryList = get_node("Window/Contents/Margin/HBox/Path_Points")

var _a_path_point: FWDebugEntryListPointEntry = null # Currently selected path point

func _ready() -> void:
	super()
	_a_Path_Points.entry_moved.connect(_on_Path_Points_entry_moved)
	_a_Path_Points.entry_select_pressed.connect(_on_Path_Points_entry_select_pressed)
	_a_Path_Points.entry_deleting.connect(_on_Path_Points_entry_deleting)

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	await _a_dimensions.nav_map_ready
	super(p_instance, p_data, p_res_data)

func close() -> void:
	_a_Path_Points.queue_free()
	super()

func _color_selected_path_point(p_color: Color) -> void:
	if is_instance_valid(_a_path_point):
		var nav_mesh_path_point: Variant = _a_path_point.get_point()
		var instance: Node = _a_gen_path.get_sprite_instance(nav_mesh_path_point)
		instance.set_modulate(p_color)

func _handle_mouse_left(p_point: Variant) -> void:
	if _a_gen_path.has_path_point(p_point):
		_a_gen_path.remove_path_point(p_point)
	else:
		_a_gen_path.add_path_point(p_point)

func _adjust_object_properties(p_properties: Dictionary) -> void:
	p_properties[&"$Main"] = {}
	
	var nav_mesh_path_points: Array = _a_gen_path.get_nav_mesh_path_points()
	if !nav_mesh_path_points.is_empty():
		var point: Variant = nav_mesh_path_points[-1]
		var pos: Variant = _grid_point_to_pos(point)
		p_properties[&"$Main"][&"position"] = pos

func _on_Preview_gui_input(p_event: InputEvent) -> void:
	super(p_event)
	
	if p_event.is_action_pressed(&"Mouse_Left"):
		var global_pos: Variant = _a_dimensions.get_global_mouse_pos()
		if global_pos:
			var point: Variant = _pos_to_grid_point(global_pos)
			_handle_mouse_left(point)

func _on_Gen_Path_path_updated() -> void:
	_a_Path_Points.clear_entries()
	
	var nav_mesh_path_points: Array = _a_gen_path.get_nav_mesh_path_points()
	var sprite_names: PackedStringArray = _a_gen_path.get_sprite_names()
	var i: int = 0
	for nav_mesh_path_point: Variant in nav_mesh_path_points:
		var sprite_name: String = sprite_names[i]
		var texture: Texture2D = load(_a_PATH_PATH % sprite_name)
		var instance: FWDebugEntryListPointEntry = _a_Path_Points.instantiate_entry_(nav_mesh_path_point)
		instance.set_type_texture.call_deferred(texture)
		_a_Path_Points.add_entry(instance)
		
		i += 1

func _on_Path_Points_entry_moved(_p_old_idx: int, _p_new_idx: int) -> void:
	var nav_mesh_path_points: Array = _a_Path_Points.get_points()
	var path_points: Array = []
	for nav_mesh_path_point in nav_mesh_path_points:
		var path_point: Variant = _a_gen_path.get_path_point(nav_mesh_path_point)
		path_points.push_back(path_point)
	
	_a_gen_path.set_path_points(path_points)

func _on_Path_Points_entry_select_pressed(p_instance: FWDebugEntryListPointEntry) -> void:
	var nav_mesh_path_point: Variant = p_instance.get_point()
	var pos: Variant = _grid_point_to_pos(nav_mesh_path_point)
	_a_free_camera.set_position(pos)
	
	_color_selected_path_point(_e_normal_color)
	
	_a_path_point = p_instance
	_color_selected_path_point(_e_selected_color)

func _on_Path_Points_entry_deleting(p_instance: FWDebugEntryListPointEntry) -> void:
	var nav_mesh_path_point: Variant = p_instance.get_point()
	var path_point: Variant = _a_gen_path.get_path_point(nav_mesh_path_point)
	_a_gen_path.remove_path_point.call_deferred(path_point)
