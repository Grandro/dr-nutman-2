extends FWDebugCommandEditCommandPreviewObject
class_name FWDebugCommandEditCommandChangeDir

const _a_SELECT_POINT_COLOR: Color = Color(0.5, 0.5, 0.5, 1.0)
const _a_NORMAL_COLOR: Color = Color.WHITE

@onready var _a_Type: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Type")
@onready var _a_Fixed_Dir: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Dir/Fixed")
@onready var _a_Look_HBox: HBoxContainer = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Dir/Look")
@onready var _a_Look_Type: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Dir/Look/Type")
@onready var _a_Look_Object: FWDebugObjectSelect = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Dir/Look/Object")
@onready var _a_Look_Degrees: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Dir/Look_Degrees")

var _a_type_box: Container = null # Box of the selected type to hide when new selected

func _ready() -> void:
	_a_Point = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Dir/Look/Point")
	super()
	
	_a_Type.selected.connect(_on_Type_selected)
	_a_Fixed_Dir.selected.connect(_on_Fixed_Dir_selected)
	_a_Look_Type.selected.connect(_on_Look_Type_selected)
	_a_Look_Object.selected.connect(_on_Look_Object_selected)
	_a_Look_Degrees.selected.connect(_on_Look_Degrees_selected)
	
	_a_Type.update_options()
	_a_Fixed_Dir.update_options()
	_a_Look_Type.update_options()
	_a_Look_Degrees.update_options()
	
	_a_Fixed_Dir.hide()
	_a_Look_HBox.hide()
	_a_Look_Degrees.hide()

func update_grid() -> void:
	super()
	if _a_Point.is_point_visible():
		_a_dimensions.update_point()
		_update_object_dir_vec()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	var point: Node = _a_Point.get_point_instance()
	_a_preview_scene.add_child(point)
	
	_selected_type_changed()
	
	_a_Window.show()
	show()

func _open_init(p_res_data: Dictionary) -> void:
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Type.load_data_init()
	_a_Fixed_Dir.load_data_init()
	_a_Look_Type.load_data_init()
	_a_Point.load_data_init()
	_a_Look_Degrees.load_data_init()

func _open_load(p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_data, p_res_data)
	_a_Object.load_data(p_data[&"Object"])
	_selected_object_changed()
	_a_Type.load_data(p_data[&"Type"])
	_a_Fixed_Dir.load_data(p_data[&"Args"][&"Dir"])
	_a_Look_Type.load_data(p_data[&"Args"][&"Type"])
	_selected_look_type_changed()
	_a_Look_Object.load_data(p_data[&"Args"][&"Object"])
	_a_Point.load_data(p_data[&"Args"][&"Point"])
	_a_dimensions.update_point()
	_a_Look_Degrees.load_data(p_data[&"Args"][&"Degrees"])

func _create_objects() -> void:
	super()
	_a_Look_Object.set_viewport(_a_preview_vp)
	_a_Look_Object.update_options()

func _update_object_dir_vec() -> void:
	var instance: Node = _a_Object.get_selected_value()
	var type: StringName = _a_Type.get_selected_key()
	var revert_dir_vec: Variant = _get_object_revert_property_value(instance, &"Movement", &"_a_shared._a_dir_vec")
	if revert_dir_vec == null:
		revert_dir_vec = _a_object.comph().call_comp("Movement", &"get_dir_vec")
	var dir_vec: Variant
	match type:
		&"Fixed_Dir":
			var dir_name: StringName = _a_Fixed_Dir.get_selected_key()
			dir_vec = Global.get_dir_name_vec(dir_name, _e_dim)
		
		&"Look_Degrees":
			var degrees: float = _a_Look_Degrees.get_selected_key()
			dir_vec = Global.get_dir_vec_rotated(revert_dir_vec, degrees)
		
		_:
			# Look_At, Look_Away
			var look_type: StringName = _a_Look_Type.get_selected_key()
			var start_pos: Variant = instance.get_position()
			match look_type:
				&"Object":
					var look_instance: Node = _a_Look_Object.get_selected_value()
					var end_pos: Variant = look_instance.get_position()
					dir_vec = end_pos - start_pos
					if type == &"Look_Away":
						dir_vec = Global.get_dir_vec_rotated(dir_vec, 180.0)
				
				&"Point":
					if _a_Point.is_point_visible():
						var point: Variant = _a_Point.get_point_vec()
						var end_pos: Variant = _grid_point_to_pos(point)
						dir_vec = end_pos - start_pos
					else:
						dir_vec = revert_dir_vec
					
					if type == &"Look_Away":
						dir_vec = Global.get_dir_vec_rotated(dir_vec, 180.0)
	
	_set_object_revert_property_value(_a_object, &"Movement", &"_a_shared._a_dir_vec", revert_dir_vec)
	instance.comph().call_comp("Movement", &"set_dir_vec", [dir_vec])
	instance.comph().call_comp("Anims", &"update_anim")

func _selected_object_changed() -> void:
	super()
	if _a_object != null:
		_revert_object_property(_a_object, &"Movement", &"_a_shared._a_dir_vec")
	
	_a_object = _a_Object.get_selected_value()
	_update_object_dir_vec()
	
	var old_allowed_classes: Array[StringName] = _a_Look_Object.get_allowed_classes()
	var allowed_classes: Array[StringName]
	if _a_object is Node2D: allowed_classes = [&"Node2D"]
	elif _a_object is Node3D: allowed_classes = [&"Node3D"]
	else: allowed_classes = [&"Node"]
	if allowed_classes != old_allowed_classes:
		_a_Look_Object.set_allowed_classes(allowed_classes)
		_a_Look_Object.update_options()

func _selected_type_changed() -> void:
	if _a_type_box != null:
		_a_type_box.hide()
	
	var selected: StringName = _a_Type.get_selected_key()
	var box: Container
	match selected:
		&"Fixed_Dir":
			box = _a_Fixed_Dir
			_set_grid_visible(false)
			_a_Point.set_point_visible(false)
		
		&"Look_Degrees":
			box = _a_Look_Degrees
			_set_grid_visible(false)
			_a_Point.set_point_visible(false)
		
		_:
			# Look_At, Look_Away
			_selected_look_type_changed()
			box = _a_Look_HBox
	
	_update_object_dir_vec()
	box.show()
	_a_type_box = box

func _selected_look_type_changed() -> void:
	var selected: StringName = _a_Look_Type.get_selected_key()
	match selected:
		&"Object":
			_set_grid_visible(false)
			_a_Point.set_point_visible(false)
			_a_Point.hide()
			_a_Look_Object.show()
		
		&"Point":
			_set_grid_visible(true)
			_a_Point.show()
			_a_Look_Object.hide()

func _set_grid_visible(p_visible: bool) -> void:
	_a_draw_grid.set_visible(p_visible)
	_a_Grid_HBox.set_visible(p_visible)

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Type"] = _a_Type.get_save_data()
	data[&"Args"] = {}
	data[&"Args"][&"Dir"] = _a_Fixed_Dir.get_save_data()
	data[&"Args"][&"Type"] = _a_Look_Type.get_save_data()
	data[&"Args"][&"Object"] = _a_Look_Object.get_save_data()
	data[&"Args"][&"Point"] = _a_Point.get_save_data()
	data[&"Args"][&"Degrees"] = _a_Look_Degrees.get_save_data()
	
	return data

func _adjust_object_properties(p_properties: Dictionary) -> void:
	p_properties[&"Movement"] = {}
	
	var dir_vec: Variant = _a_object.comph().call_comp("Movement", &"get_dir_vec")
	p_properties[&"Movement"][&"_a_shared._a_dir_vec"] = dir_vec

func _on_Preview_gui_input(p_event: InputEvent) -> void:
	super(p_event)
	
	var type: StringName = _a_Type.get_selected_key()
	var look_type: StringName = _a_Look_Type.get_selected_key()
	if type.begins_with("Look") && look_type == &"Point":
		if p_event.is_action_pressed(&"Mouse_Left"):
			var global_pos: Variant = _a_dimensions.get_global_mouse_pos()
			if global_pos:
				var point: Variant = _pos_to_grid_point(global_pos)
				var curr_point: Variant = _a_Point.get_point_vec()
				if curr_point == point && _a_Point.is_point_visible():
					_a_Point.set_point_visible(false)
				else:
					_a_Point.set_point_vec(point)
					_a_dimensions.update_point()
					_a_Point.set_point_visible(true)
			
			_update_object_dir_vec()

func _on_Type_selected() -> void:
	_selected_type_changed()

func _on_Fixed_Dir_selected() -> void:
	_update_object_dir_vec()

func _on_Look_Type_selected() -> void:
	_selected_look_type_changed()
	_update_object_dir_vec()

func _on_Look_Object_selected() -> void:
	_update_object_dir_vec()

func _on_Look_Degrees_selected() -> void:
	_update_object_dir_vec()
