extends FWDebugFixWarningsEntryBase
class_name FWDebugFixWarningsEntryFile

@onready var _a_New_Value: Label = get_node("VBox/New/Value")
@onready var _a_Select: Button = get_node("Select")
@onready var _a_File: FileDialog = get_node("File")

func _ready() -> void:
	super()
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_File.file_selected.connect(_on_File_file_selected)
	
	var dir_path: String = _a_warning.get_dir_path()
	var filters: PackedStringArray = _a_warning.get_filters()
	_a_File.set_current_dir(dir_path)
	_a_File.set_filters(filters)

func _on_Select_pressed() -> void:
	_a_File.popup_centered(Vector2(480, 660))

func _on_File_file_selected(p_path: String) -> void:
	_a_New_Value.set_text(p_path)
	_a_new_value = p_path
