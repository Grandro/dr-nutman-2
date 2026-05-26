extends FWDebugCommandEditCommandPreviewObject
class_name FWDebugCommandEditCommandChangeState

@onready var _a_State: FWDebugValueSelectOptions = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/State")

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(p_res_data: Dictionary) -> void:
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_State.load_data_init()

func _open_load(p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_data, p_res_data)
	_a_Object.load_data(p_data[&"Object"])
	_selected_object_changed()
	_a_State.load_data(p_data[&"State"])

func _selected_object_changed() -> void:
	super()
	
	_a_object = _a_Object.get_selected_value()
	var states: Array[StringName] = _a_object.comph().call_comp("States", &"get_states")
	_a_State.set_options(states)
	_a_State.update_options()

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"State"] = _a_State.get_save_data()
	
	return data

func _adjust_object_properties(p_properties: Dictionary) -> void:
	p_properties[&"States"] = {}
	
	var state: StringName = _a_State.get_selected_key()
	p_properties[&"States"][&"_e_state"] = state
	p_properties[&"States"][&"_a_state_tmp"] = state
