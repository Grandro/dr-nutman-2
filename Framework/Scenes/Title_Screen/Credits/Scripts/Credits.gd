extends Control
class_name FWTitleScreenCredits

@onready var _a_Back: FWIndicatorButton = get_node("Back")
@onready var _a_Godot_Engine_Text: Label = get_node("Margin/VBox/Scroll/VBox/Godot_Engine/Text")

func _ready() -> void:
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	var license_text: String = Engine.get_license_text()
	_a_Godot_Engine_Text.set_text(license_text)

func _unhandled_input(p_event: InputEvent) -> void:
	if p_event.is_action_pressed(&"ui_cancel"):
		_close()

func open() -> void:
	show()

func _close() -> void:
	hide()

func _on_Back_select_pressed() -> void:
	_close()
