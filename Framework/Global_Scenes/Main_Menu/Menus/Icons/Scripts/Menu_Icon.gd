extends VBoxContainer
class_name MainMenuMenuIcon

signal pressed()

@export var _e_key: StringName = &""
@export var _e_menu_scene: PackedScene = null
@export_enum("Menu", "Sub_Menu") var _e_type: String = "Menu"

const _a_BASE_LOC_ID: String = "FW_MAIN_MENU_%s"

var _a_Outline_Shader: ShaderMaterial = preload("uid://bqc55y1g0cpkv")

@onready var _a_Image: TextureButton = get_node("Image")
@onready var _a_Desc: Label = get_node("Desc")

func _ready() -> void:
	_a_Image.pressed.connect(_on_Image_pressed)
	_a_Image.focus_entered.connect(_on_Image_focus_entered)
	_a_Image.focus_exited.connect(_on_Image_focus_exited)
	
	var fav_color: Color = Global_Data.get_fav_color()
	_a_Outline_Shader.set_shader_parameter(&"line_color", fav_color)
	_a_Outline_Shader.set_shader_parameter(&"line_thickness", 2.0)
	_a_Desc.set_text(tr(_a_BASE_LOC_ID % _e_key.to_upper()))

func grab_image_focus() -> void:
	_a_Image.grab_focus()

func set_image_disabled(p_disabled: bool) -> void:
	_a_Image.set_disabled(p_disabled)

func get_key() -> StringName:
	return _e_key

func get_menu_scene() -> PackedScene:
	return _e_menu_scene

func get_type() -> StringName:
	return _e_type

func _on_Image_pressed() -> void:
	pressed.emit()

func _on_Image_focus_entered() -> void:
	_a_Image.set_material(_a_Outline_Shader)

func _on_Image_focus_exited() -> void:
	_a_Image.set_material(null)
