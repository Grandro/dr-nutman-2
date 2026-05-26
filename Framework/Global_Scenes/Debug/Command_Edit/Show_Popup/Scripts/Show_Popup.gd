extends FWDebugCommandEditCommandPreviewObject
class_name FWDebugCommandEditCommandShowPopup

@onready var _a_Type: FWDebugCommandEditCommandShowPopupType = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Type")
@onready var _a_Wait_Finish: FWDebugValueSelectBool = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

func _ready() -> void:
	super()
	_a_Type.selected.connect(_on_Type_selected)
	
	_a_Type.update_options()

func open(p_instance: FWDebugCommandEditorEntryBase, p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_instance, p_data, p_res_data)
	
	_selected_type_changed()
	
	_a_Window.show()
	show()

func _open_init(p_res_data: Dictionary) -> void:
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Type.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data: Dictionary, p_res_data: Dictionary) -> void:
	super(p_data, p_res_data)
	_a_Object.load_data(p_data[&"Object"])
	_selected_object_changed()
	_a_Type.load_data(p_data[&"Type"])
	_a_Wait_Finish.load_data(p_data[&"Wait_Finish"])

func _selected_object_changed() -> void:
	super()
	if _a_object != null:
		_a_object.comph().call_comp("Popup", &"play_anim", [&"Fade_Out"])
	
	var selected: Node = _a_Object.get_selected_value()
	var type: StringName = _a_Type.get_selected_key()
	selected.comph().call_comp("Popup", &"popup", [type, false])
	
	_a_object = selected

func _selected_type_changed() -> void:
	var type: StringName = _a_Type.get_selected_key()
	_a_object.comph().call_comp("Popup", &"update_texture", [type])

func _get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Type"] = _a_Type.get_save_data()
	data[&"Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _on_Type_selected() -> void:
	_selected_type_changed()
