extends FWDebugCommandEditCommandPreviewObjectPath
class_name FWDebugCommandEditCommandSetMoveRoute

@onready var _a_State: FWDebugCommandEditCommandSetMoveRouteState = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/State")
@onready var _a_Speed: FWDebugValueSelectSlider = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Speed")
@onready var _a_Wait_Finish: FWDebugValueSelectBool = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

var _a_last_dir_vec: StringName # Current last_dir_vec of selected object by Draw_Path

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	await super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(p_res_data: Dictionary) -> void:
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_State.load_data_init()
	if _a_State.has_key(&"Walk"):
		_a_State.select(&"Walk")
	_a_Speed.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_data, p_res_data)
	_a_Object.load_data(p_data[&"Object"])
	_selected_object_changed()
	_a_State.load_data(p_data[&"State"])
	_a_Speed.load_data(p_data[&"Speed"])
	_a_Wait_Finish.load_data(p_data[&"Wait_Finish"])

func _selected_object_changed() -> void:
	super()
	
	_a_object = _a_Object.get_selected_value()
	var states: Array[StringName] = _a_object.comph().call_comp("States", &"get_states")
	_a_State.set_options(states)
	_a_State.update_options()

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"State"] = _a_State.get_save_data()
	data[&"Speed"] = _a_Speed.get_save_data()
	data[&"Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _adjust_object_properties(p_properties: Dictionary) -> void:
	super(p_properties)
	
	var nav_mesh_path_points: Array = _a_gen_path.get_nav_mesh_path_points()
	if nav_mesh_path_points.size() > 1:
		p_properties[&"Movement"] = {}
		p_properties[&"Movement"][&"_a_shared._a_dir_vec"] = _a_last_dir_vec

func _on_Gen_Path_last_dir_name_changed(p_dir_name: StringName) -> void:
	_a_last_dir_vec = Global.get_dir_name_vec(p_dir_name, _e_dim)
