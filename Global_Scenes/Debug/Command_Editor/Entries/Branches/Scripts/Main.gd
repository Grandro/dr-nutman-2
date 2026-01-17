extends DebugCommandEditorBranchBase
class_name DebugCommandEditorBranchMain

signal warning_pressed()

var _a_Mark_Default_Image: Texture2D = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Branches/Sprites/Mark_Default.png")
var _a_Mark_Test_Image: Texture2D = preload("res://Global_Scenes/Debug/Command_Editor/Entries/Branches/Sprites/Mark_Test.png")

@onready var _a_Base_Mark: TextureRect = get_node("Base/HBox/Mark")
@onready var _a_Base_Args: Label = get_node("Base/HBox/Args")
@onready var _a_Warning: TextureButton = get_node("Base/HBox/Warning")
@onready var _a_Args: VBoxContainer = get_node("Args")

func _ready() -> void:
	super()
	_a_Warning.pressed.connect(_on_Warning_pressed)
	
	_a_Warning.hide()

func add_args_child(p_child: DebugCommandEditorArgEntry) -> void:
	_a_Args.add_child(p_child)

func set_mark(p_mark: StringName) -> void:
	match p_mark:
		&"Default": _a_Base_Mark.set_texture(_a_Mark_Default_Image)
		&"Test": _a_Base_Mark.set_texture(_a_Mark_Test_Image)

func set_base_args_modulate(p_color: Color) -> void:
	_a_Base_Args.set_modulate(p_color)

func set_base_args(p_args: String) -> void:
	_a_Base_Args.set_text(p_args)

func get_args_children() -> Array[Node]:
	return _a_Args.get_children()

func set_warning_visible(p_visible: bool) -> void:
	_a_Warning.set_visible(p_visible)

func get_warning_global_pos() -> Vector2:
	return _a_Warning.get_global_position()

func _on_Warning_pressed() -> void:
	warning_pressed.emit()
