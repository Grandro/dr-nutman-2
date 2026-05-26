extends FWProgressQuestBase
class_name ProgressQuestGropingInTheDarkPrepareBatteries

var _a_first_projector_lamp: bool = true

func set_first_projector_lamp(p_first_projector_lamp: bool) -> void:
	_a_first_projector_lamp = p_first_projector_lamp

func get_first_projector_lamp() -> bool:
	return _a_first_projector_lamp

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"First_Projector_Lamp"] = _a_first_projector_lamp
	
	return data

func load_file_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_first_projector_lamp = p_data[&"First_Projector_Lamp"]
