extends DebugValueSelect
class_name DebugValueSelectImage

signal file_path_changed(p_file_path: String)

@onready var _a_Value: DebugImageSelect = get_node("Value")

func _ready() -> void:
	super()
	_a_Value.file_path_changed.connect(_on_Value_file_path_changed)

func get_image_texture() -> Texture2D:
	return _a_Value.get_image_texture()

func get_save_data() -> Dictionary:
	var data: Dictionary = super()
	data[&"Value"] = _a_Value.get_file_path()
	
	return data

func load_data(p_data: Dictionary) -> void:
	super(p_data)
	_a_Value.set_file_path(p_data[&"Value"])

func _on_Var_Select_active_toggled(p_toggled: bool) -> void:
	_a_Value.set_disabled(p_toggled)

func _on_Value_file_path_changed(p_file_path: String) -> void:
	file_path_changed.emit(p_file_path)
