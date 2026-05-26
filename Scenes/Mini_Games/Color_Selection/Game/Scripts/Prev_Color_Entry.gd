extends Control
class_name MiniGameColorSelectionPrevColorEntry

signal pressed()
signal delete_pressed()

@onready var _a_Color: TextureButton = get_node("Color")
@onready var _a_New: RichTextLabel = get_node("New")
@onready var _a_Delete: MarginContainer = get_node("Delete")
@onready var _a_Delete_Image: TextureButton = get_node("Delete/Image")

var _a_deletable: bool = true

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_a_Color.pressed.connect(_on_Color_pressed)
	_a_Delete_Image.pressed.connect(_on_Delete_Image_pressed)
	
	_a_New.hide()
	_a_Delete.hide()

func set_self_color(p_color: Color) -> void:
	_a_Color.set_self_modulate(p_color)
	var text_color: Color = Global.get_text_color_for_bg(p_color)
	_a_Delete.set_modulate(text_color)

func get_self_color() -> Color:
	return _a_Color.get_self_modulate()

func set_new_visible(p_visible: bool) -> void:
	_a_New.set_visible(p_visible)

func set_deletable(p_deletable: bool) -> void:
	if !p_deletable:
		_a_Delete.hide()
	
	_a_deletable = p_deletable

func _on_mouse_entered() -> void:
	if _a_deletable:
		_a_Delete.show()

func _on_mouse_exited() -> void:
	if _a_deletable:
		_a_Delete.hide()

func _on_Color_pressed() -> void:
	pressed.emit()

func _on_Delete_Image_pressed() -> void:
	delete_pressed.emit()
