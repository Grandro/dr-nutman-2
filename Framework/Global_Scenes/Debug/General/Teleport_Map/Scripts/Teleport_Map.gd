extends HBoxContainer
class_name FWDebugGeneralTeleportMap

@onready var _a_Select: Button = get_node("Select")

func _ready() -> void:
	_a_Select.pressed.connect(_on_Select_pressed)

func _on_Select_pressed() -> void:
	Debug.open_teleport_map()
