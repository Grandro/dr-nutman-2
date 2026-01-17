extends Node3D
class_name SVEncounterIndicatorCommandCircle

@onready var _a_Button_Anims: AnimationPlayer = get_node("Button/Anims")
@onready var _a_Canvas: CanvasLayer = get_node("Canvas")
@onready var _a_Command_Text: Label = get_node("Canvas/Command/Margin/Text")
@onready var _a_Command_Anims: AnimationPlayer = get_node("Canvas/Command/Anims")

func _ready() -> void:
	_a_Canvas.hide()
	hide()

func open(p_pos: Vector3) -> void:
	var offset: Vector3 = Vector3(-1, -1.5, 0.0)
	set_global_position(p_pos + offset)
	_a_Button_Anims.play(&"Blink")
	_a_Command_Anims.play(&"Fade_In")
	
	_a_Canvas.show()
	show()

func close() -> void:
	_a_Button_Anims.stop()
	
	_a_Canvas.hide()
	hide()

func set_command_text(p_text: String) -> void:
	_a_Command_Text.set_text(p_text)
