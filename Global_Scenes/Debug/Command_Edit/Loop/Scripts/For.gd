extends DebugCommandEditMenuBase
class_name DebugCommandEditCommandLoopFor

@onready var _a_Idx: DebugCommandEditValueSelectChar = get_node("VBox/Idx")
@onready var _a_Start: DebugValueSelectNum = get_node("VBox/Start")
@onready var _a_End: DebugValueSelectNum = get_node("VBox/End")
@onready var _a_Step: DebugValueSelectNum = get_node("VBox/Step")

func open(p_data: Dictionary, p_res_data: Dictionary) -> void:
	_a_Idx.set_taken_idx_ords(p_res_data[&"Misc"][&"For_Loop_Idx_Ords"])
	if p_data.is_empty():
		_open_init()
	else:
		_open_load(p_data)
	
	show()

func _open_init() -> void:
	_a_Idx.load_data_init()
	_a_Start.load_data_init()
	_a_End.load_data_init()
	_a_Step.load_data_init()

func _open_load(p_data: Dictionary) -> void:
	_a_Idx.load_data(p_data[&"Idx"])
	_a_Start.load_data(p_data[&"Start"])
	_a_End.load_data(p_data[&"End"])
	_a_Step.load_data(p_data[&"Step"])

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Idx"] = _a_Idx.get_save_data()
	data[&"Start"] = _a_Start.get_save_data()
	data[&"End"] = _a_End.get_save_data()
	data[&"Step"] = _a_Step.get_save_data()
	
	return data
