extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@onready var _a_Avoidance = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Avoidance")

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Avoidance.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Avoidance.load_data(p_data["Avoidance"])

func _get_save_data():
	var data = super()
	data["Avoidance"] = _a_Avoidance.get_save_data()
	
	return data
