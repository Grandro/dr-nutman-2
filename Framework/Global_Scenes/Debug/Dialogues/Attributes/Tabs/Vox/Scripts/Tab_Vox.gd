extends FWDebugDialoguesAttributesTabBase
class_name FWDebugDialoguesAttributesTabVox

@onready var _a_Object: FWDebugObjectSelect = get_node("Margin/HSplit/Left/Object")
@onready var _a_Custom: CheckBox = get_node("Margin/HSplit/Left/Custom/VBox_1/Value")
@onready var _a_Custom_VBox_2: VBoxContainer = get_node("Margin/HSplit/Left/Custom/VBox_2")
@onready var _a_Custom_File_Audio: FWDebugAudioSelect = get_node("Margin/HSplit/Left/Custom/VBox_2/File/Audio")
@onready var _a_Custom_Pitch: FWDebugFloatEdit = get_node("Margin/HSplit/Left/Custom/VBox_2/Pitch/Value")

var _a_object_edited: bool = false # Manually changed selected object?

func _ready() -> void:
	_a_Object.selected.connect(_on_Object_selected)
	_a_Custom.pressed.connect(_on_Custom_pressed)
	_a_Custom_Pitch.value_changed.connect(_on_Custom_Pitch_value_changed)
	Scene_Manager.scene_changed.connect(_on_Scene_Manager_scene_changed)
	
	var root_vp: Window = get_tree().get_root()
	_a_Object.set_viewport(root_vp)
	
	_a_Custom_VBox_2.hide()

func open(p_data: Dictionary) -> void:
	_a_Object.select(p_data[&"Object"])
	_a_Custom.set_pressed(p_data[&"Custom"][&"Active"])
	_a_Custom_File_Audio.set_audio_stream(p_data[&"Custom"][&"Path"])
	_a_Custom_Pitch.set_value(p_data[&"Custom"][&"Pitch"])
	_custom_pressed_changed()
	
	_a_object_edited = false

func open_init() -> void:
	_a_Custom.set_pressed(false)
	_a_Custom_File_Audio.set_audio_stream("")
	_a_Custom_Pitch.set_value(1.0)
	_custom_pressed_changed()
	
	_a_object_edited = false

func select_object(p_key: StringName) -> void:
	_a_Object.select(p_key)

func _custom_pressed_changed() -> void:
	var is_pressed: bool = _a_Custom.is_pressed()
	_a_Object.set_disabled(is_pressed)
	_a_Custom_VBox_2.set_visible(is_pressed)

func get_object_edited() -> bool:
	return _a_object_edited

func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data[&"Object"] = _a_Object.get_selected_key()
	data[&"Custom"] = {}
	data[&"Custom"][&"Active"] = _a_Custom.is_pressed()
	data[&"Custom"][&"Path"] = _a_Custom_File_Audio.get_stream_path()
	data[&"Custom"][&"Pitch"] = _a_Custom_Pitch.get_value()
	
	return data

func _on_Object_selected() -> void:
	_a_object_edited = true

func _on_Custom_pressed() -> void:
	_custom_pressed_changed()

func _on_Custom_Pitch_value_changed(p_value: float) -> void:
	_a_Custom_File_Audio.set_pitch_scale(p_value)

func _on_Scene_Manager_scene_changed(_p_instance: Node, _p_loaded_file_data: bool) -> void:
	_a_Object.update_options()
