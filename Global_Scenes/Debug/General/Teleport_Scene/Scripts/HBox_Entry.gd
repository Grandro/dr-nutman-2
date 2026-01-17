extends HBoxContainer
class_name DebugGeneralTeleportSceneHBoxEntry

signal select_pressed()

@onready var _a_Select: Button = get_node("Select")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)

func set_select_text(p_text: String) -> void:
	_a_Select.set_text(p_text)

func _on_Select_pressed() -> void:
	select_pressed.emit()
