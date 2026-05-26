extends FWDebugDialoguesAttributesTabBase
class_name FWDebugDialoguesAttributesTabSprites

@onready var _a_Left_Image: FWDebugImageSelect = get_node("Margin/HSplit/Left/Left/Image")
@onready var _a_Right_Image: FWDebugImageSelect = get_node("Margin/HSplit/Left/Right/Image")
@onready var _a_Mini_Bust_Image: FWDebugImageSelect = get_node("Margin/HSplit/Left/Mini_Bust/Image")

func open(p_data: Dictionary) -> void:
	_a_Left_Image.set_file_path(p_data[&"Left"])
	_a_Right_Image.set_file_path(p_data[&"Right"])
	_a_Mini_Bust_Image.set_file_path(p_data[&"Mini_Bust"])

func open_init() -> void:
	_a_Left_Image.set_file_path("")
	_a_Right_Image.set_file_path("")
	_a_Mini_Bust_Image.set_file_path("")

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Left"] = _a_Left_Image.get_file_path()
	data[&"Right"] = _a_Right_Image.get_file_path()
	data[&"Mini_Bust"] = _a_Mini_Bust_Image.get_file_path()
	
	return data
