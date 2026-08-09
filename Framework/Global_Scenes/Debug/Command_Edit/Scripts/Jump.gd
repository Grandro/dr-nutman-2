extends FWDebugCommandEditCommandPreviewObject
class_name FWDebugCommandEditCommandJump

@onready var _a_Keep_Dir: FWDebugValueSelectBool = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Keep_Dir")
@onready var _a_Wait_Finish: FWDebugValueSelectBool = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

func _ready() -> void:
	_a_Point = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Point")
	super()

func update_grid() -> void:
	super()
	if _a_Point.is_point_visible():
		_a_dimensions.update_point()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_selected_object_changed()
	
	var point: Node = _a_Point.get_point_instance()
	_a_preview_scene.add_child(point)
	
	_a_Window.show()
	show()

func _open_init(p_res_data: Dictionary) -> void:
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Point.load_data_init()
	_a_Keep_Dir.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_data, p_res_data)
	_a_Object.load_data(p_data[&"Object"])
	_selected_object_changed()
	_a_Point.load_data(p_data[&"Point"])
	_a_Keep_Dir.load_data(p_data[&"Keep_Dir"])
	_a_Wait_Finish.load_data(p_data[&"Wait_Finish"])

func _selected_object_changed() -> void:
	super()
	_a_object = _a_Object.get_selected_value()

func get_point_instance() -> FWDebugValueSelectPointBase:
	return _a_Point

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Point"] = _a_Point.get_save_data()
	data[&"Keep_Dir"] = _a_Keep_Dir.get_save_data()
	data[&"Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _adjust_object_properties(p_properties: Dictionary) -> void:
	var point_selected: bool = _a_Point.is_point_visible()
	if point_selected:
		p_properties[&"$Main"] = {}
		
		var pos: Variant = _a_Point.get_point_pos()
		p_properties[&"$Main"][&"position"] = pos
		
		var keep_dir: bool = _a_Keep_Dir.is_pressed()
		if !keep_dir:
			p_properties[&"Movement"] = {}
			
			var instance: Node = _a_Object.get_selected_value()
			var from: Variant = instance.get_position()
			var dir_vec: Variant = pos - from
			p_properties[&"Movement"][&"_a_shared._a_dir_vec"] = dir_vec

func _on_Preview_gui_input(p_event: InputEvent) -> void:
	super(p_event)
	
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
